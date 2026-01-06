// © 2026  Cristian Felipe Patiño Rojas. Created on 3/1/26.

import SwiftUI

// --- EL BUG: DEMOSTRACIÓN ---

struct BugDemoView: View {
    @State private var showList = true
    
    var body: some View {
        VStack {
            Button("Alternar Vista (Simular Navegación/Cambio)") {
                showList.toggle()
            }
            
            if showList {
                // Aquí usamos tu composer actual
                compose_2(loader: SlowLoader())
            } else {
                Text("La vista ha sido destruida")
            }
        }
    }
}

// Un loader que tarda 5 segundos para darnos tiempo a romperlo
class SlowLoader: MoviesLoader {
    func load() async throws -> [Movie] {
        print("🚀 Loader: Iniciando carga pesada...")
        try await Task.sleep(for: .seconds(5))
        print("✅ Loader: Carga finalizada (si lees esto, no hubo bug)")
        return [Movie(id: "1", title: "Inception", poster_url: "", release_year: 2010)]
    }
}

@main
struct CourseApp: App {
    
    class MockLoader: MoviesLoader {
        
        var count = 0
        
        func load() async throws -> [Movie] {
            try await Task.sleep(for: .seconds(1))
            count += 1
            return (1...count).map {
                anyMovie(id: "\($0)", title: "Movie \($0)")
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            BugDemoView()
        }
    }
}

// © 2026  Cristian Felipe Patiño Rojas. Created on 6/1/26.

// © 2026  Cristian Felipe Patiño Rojas. Created on 5/1/26.


import SwiftUI

// UI module
extension MoviesList {
    @Observable class Store {
        var error: String?
        var isLoading = true
        var movies: [Movie]?
        
        var showEmpty: Bool {
            movies != nil && (movies ?? []).isEmpty
        }
    }
}

fileprivate struct MoviesList: View {
    @State var store = Store()
    var body: some View {
        List {
            if let movies = store.movies {
                ForEach(movies) { Cell(movie: $0) }
            }
        }
        .overlay { if store.isLoading { ProgressView() } }
        .overlay { if let m = store.error { Error(label: m) } }
        .overlay { if store.showEmpty { Empty() } }
    }
}

extension MoviesList {
    struct Error: View {
        let label: String
        var body: some View {
            VStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.title)
                    .opacity(0.6)
                Text(label)
            }
        }
    }
}


extension MoviesList {
     struct Empty: View {
        var body: some View {
            Image(systemName: "film.stack")
                .font(.title)
                .opacity(0.6)
        }
    }
}


extension MoviesList {
    struct Cell: View {
        let movie: Movie
        var body: some View {
            HStack(spacing: 12) {
                AsyncImage(url: URL(string: movie.poster_url)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 40)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                VStack(alignment: .leading) {
                    Text(movie.title)
                    Text(movie.release_year.description)
                        .font(.footnote)
                        .opacity(0.5)
                }
            }
        }
    }
}


// Presentation module
extension MoviesPresenter {
    protocol LoadingView {
        func displayLoading(_ bool: Bool)
    }

    protocol ErrorView {
        func displayError(_ message: String?)
    }

    protocol MovieListView {
        func displayMovies(_ movies: [Movie])
    }
}

@MainActor
fileprivate class MoviesPresenter {
    
    let loader: MoviesLoader
    
    let listView: MovieListView
    let errorView: ErrorView
    let loadingView: LoadingView
    
    deinit {
            print("💀 ERROR: El Presenter ha MUERTO antes de terminar la carga")
        }
    
    
    init(
        loader: MoviesLoader,
        listView: MovieListView,
        errorView: ErrorView,
        loadingView: LoadingView
    ) {
        self.loader = loader
        self.listView = listView
        self.errorView = errorView
        self.loadingView = loadingView
    }
    
    
    func load() async {
        do {
            loadingView.displayLoading(true)
            listView.displayMovies(try await loader.load())
            loadingView.displayLoading(false)
        } catch {
            errorView.displayError(error.localizedDescription)
            loadingView.displayLoading(false)
        }
    }
}



extension MoviesList: MoviesPresenter.LoadingView {
    func displayLoading(_ bool: Bool) {
        store.isLoading = bool
    }
}

extension MoviesList: MoviesPresenter.MovieListView {
    func displayMovies(_ movies: [Movie]) {
        store.movies = movies
    }
}


extension MoviesList: MoviesPresenter.ErrorView {
    func displayError(_ message: String?) {
        store.error = message
    }
}


fileprivate protocol MoviesLoader {
    func load() async throws -> [Movie]
}


@MainActor
fileprivate func compose_2(loader l: MoviesLoader) -> some View {
    let v = MoviesList(store: .init())

    let p = MoviesPresenter(
        loader: l,
        listView: v,
        errorView: v,
        loadingView: v
    )
   
    return v
//        .refreshable(action: p.load)
        .task(p.load)
}


#Preview {
    class MockLoader: MoviesLoader {
        func load() async throws -> [Movie] {
            try await Task.sleep(for: .seconds(2))
            return [mockMovie()]
        }
    }

    return compose_2(loader: MockLoader())
}

