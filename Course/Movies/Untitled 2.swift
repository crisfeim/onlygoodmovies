// © 2026  Cristian Felipe Patiño Rojas. Created on 5/1/26.


import SwiftUI

// UI Module
fileprivate struct ActivityIndicator: View {
    @Binding var isLoading: Bool
    var body: some View {
        if isLoading {
            ProgressView()
        }
    }
}

fileprivate struct ErrorView: View {
    @Binding var errorMessage: String?
    var body: some View {
        if let errorMessage {
            VStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.title)
                    .opacity(0.6)
                Text(errorMessage)
            }
        }
    }
}

fileprivate struct MoviesList: View {
    @Binding var movies: [Movie]?
    var body: some View {
        List {
            if let movies {
                ForEach(movies) { MovieCell(movie: $0) }
            }
        }
        .overlay(MoviesEmptyView(isShown: movies?.isEmpty ?? false))
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

fileprivate struct MoviesScreen: View {
    let indicator: ActivityIndicator
    let movies: MoviesList
    let error: ErrorView
    
    var body: some View {
        movies
            .overlay(indicator)
            .overlay(error)
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


// Composition module
extension ActivityIndicator: MoviesPresenter.LoadingView {
    func displayLoading(_ bool: Bool) {
        isLoading = bool
    }
}

extension MoviesList: MoviesPresenter.MovieListView {
    func displayMovies(_ movies: [Movie]) {
        self.movies = movies
    }
}


extension ErrorView: MoviesPresenter.ErrorView {
    func displayError(_ message: String?) {
        errorMessage = message
    }
}


@Observable fileprivate class Store {
    var isLoading = false
    var movies: [Movie]?
    var errorMessage: String?
    var isEmpty = false
}

fileprivate protocol MoviesLoader {
    func load() async throws -> [Movie]
}


fileprivate func compose(loader: MoviesLoader) -> some View {
    @State var store = Store()
    let i = ActivityIndicator(isLoading: $store.isLoading)
    let m = MoviesList(movies: $store.movies)
    let e = ErrorView(errorMessage: $store.errorMessage)

    let p = MoviesPresenter(
        loader: loader,
        moviesListView: m,
        errorView: e,
        loadingView: i
    )
    
    return MoviesScreen(indicator: i, movies: m, error: e)
        .task(p.load)
}


#Preview {
    class MockLoader: MoviesLoader {
        func load() async throws -> [Movie] {
            try await Task.sleep(for: .seconds(1))
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
