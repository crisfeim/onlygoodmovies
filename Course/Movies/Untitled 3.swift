// © 2026  Cristian Felipe Patiño Rojas. Created on 5/1/26.


import SwiftUI


fileprivate struct ErrorView: View {
    let message: String
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.title)
                .opacity(0.6)
            Text(message)
        }
    }
}


fileprivate struct MoviesList: View {
    @Binding var errorMessage: String?
    @Binding var isLoading: Bool
    @Binding var movies: [Movie]?
    var body: some View {
        List {
            if let movies {
                ForEach(movies) { MovieCell(movie: $0) }
            }
        }
        .overlay { if isLoading { ProgressView() } }
        .overlay { if let errorMessage { ErrorView(message: errorMessage) } }
    }
}


fileprivate struct MoviesEmptyView: View {
    let isShown: Bool
    var body: some View {
        if isShown {
            Image(systemName: "film.stack")
                .font(.title)
                .opacity(0.6)
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
    
    protocol MoviesEmptyView {
        func displayEmptyView(_ isShown: Bool)
    }

}

fileprivate class MoviesPresenter {
    
    let loader: MoviesLoader
    
    let moviesListView: MovieListView
    let errorView: ErrorView
    let loadingView: LoadingView
    
    
    init(
        loader: MoviesLoader,
        moviesListView: MovieListView,
        errorView: ErrorView,
        loadingView: LoadingView
    ) {
        self.loader = loader
        self.moviesListView = moviesListView
        self.errorView = errorView
        self.loadingView = loadingView
    }
    
    func load() async {
        do {
            loadingView.displayLoading(true)
            let movies = try await loader.load()
            moviesListView.displayMovies(movies)
            loadingView.displayLoading(false)
        } catch {
            errorView.displayError(error.localizedDescription)
            loadingView.displayLoading(false)
        }
    }
}



extension MoviesList: MoviesPresenter.LoadingView {
    func displayLoading(_ bool: Bool) {
        isLoading = bool
    }
}

extension MoviesList: MoviesPresenter.MovieListView {
    func displayMovies(_ movies: [Movie]) {
        self.movies = movies
    }
}


extension MoviesList: MoviesPresenter.ErrorView {
    func displayError(_ message: String?) {
        errorMessage = message
    }
}


@Observable fileprivate class Store {
    var isLoading = false
    var movies: [Movie]?
    var errorMessage: String?
}

fileprivate protocol MoviesLoader {
    func load() async throws -> [Movie]
}


fileprivate func compose(loader: MoviesLoader) -> some View {
    @State var store = Store()
    let m = MoviesList(
        errorMessage: $store.errorMessage,
        isLoading: $store.isLoading,
        movies: $store.movies 
    )

    let p = MoviesPresenter(
        loader: loader,
        moviesListView: m,
        errorView: m,
        loadingView: m
    )
    
    return m.task(p.load)
}


#Preview {
    class MockLoader: MoviesLoader {
        func load() async throws -> [Movie] {
            try await Task.sleep(for: .seconds(2))
            return [mockMovie()]
        }
    }

    return compose(loader: MockLoader())
}



fileprivate struct MovieCell: View {
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
