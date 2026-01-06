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
    protocol LoadingView   { func displayLoading(_ bool: Bool)     }
    protocol ErrorView     { func displayError(_ message: String?) }
    protocol MovieListView { func displayMovies(_ movies: [Movie]) }
}

@MainActor
fileprivate class MoviesPresenter {
    
    let loader: MoviesLoader
    
    let listView: MovieListView
    let errorView: ErrorView
    let loadingView: LoadingView
    
    
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
    
    func load_b() {
        loadingView.displayLoading(true)
        Task { [weak self] in
            guard let self else { return }
            do {
                self.listView.displayMovies(try await loader.load())
                self.loadingView.displayLoading(false)
            } catch {
                self.errorView.displayError(error.localizedDescription)
                self.loadingView.displayLoading(false)
            }
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


fileprivate protocol MoviesLoader: Sendable {
    func load() async throws -> [Movie]
}



@MainActor
fileprivate func compose_2(loader l: MoviesLoader) -> some View {
    let v = MoviesList()

    let p = MoviesPresenter(
        loader: l,
        listView: v,
        errorView: v,
        loadingView: v
    )
   
    return v.task(p.load)
}


#Preview {
    final class MockLoader: MoviesLoader {
         func load() async throws -> [Movie] {[mockMovie()]}
    }
    
    final class LoaderDecorator: MoviesLoader {
        let loader: MoviesLoader
        let cache = MoviesCache()
        init(loader: MoviesLoader) {
            self.loader = loader
        }
        
        func load() async throws -> [Movie] {
            try await Pipeline(loader.load)
                .handle(effects: cache.save)
                .delay(for: 3)
                .fetch()
        }
    }

 

    return compose_2(loader: LoaderDecorator(loader: MockLoader()))
}

actor MoviesCache {
    func save(_ movies: [Movie]) async {}
}


