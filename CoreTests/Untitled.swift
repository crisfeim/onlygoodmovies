// © 2026  Cristian Felipe Patiño Rojas. Created on 6/1/26.

// © 2026  Cristian Felipe Patiño Rojas. Created on 5/1/26.

import XCTest

struct Movie: Identifiable, Decodable {
    let id: String
    let title: String
    let poster_url: String
    let release_year: Int
}


fileprivate class PresenterTests: XCTestCase {
    class MockLoader: MoviesLoader {
        func load() async throws -> [Movie] {
            return []
        }
    }
    
    @MainActor
    func test() {
        let s = MoviesList.Store()
        let v = MoviesList(store: s)

        let p = MoviesPresenter(
            loader: MockLoader(),
            listView: v,
            errorView: v,
            loadingView: v
        )
        
        trackForMemoryLeaks(s)
        trackForMemoryLeaks(p)
    }
    
}

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
    let store: Store
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
    @MainActor protocol LoadingView {
        func displayLoading(_ bool: Bool)
    }

    @MainActor protocol ErrorView {
        func displayError(_ message: String?)
    }

    @MainActor protocol MovieListView {
        func displayMovies(_ movies: [Movie])
    }
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
fileprivate func compose_2(loader: MoviesLoader) -> some View {
    let store = MoviesList.Store()
    let m = MoviesList(store: store)

    let p = MoviesPresenter(
        loader: loader,
        listView: m,
        errorView: m,
        loadingView: m
    )
   
    return m.task(p.load)
}


fileprivate class MockLoader: MoviesLoader {
    func load() async throws -> [Movie] {[]}
}



