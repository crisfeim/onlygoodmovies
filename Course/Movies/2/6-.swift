// © 2026  Cristian Felipe Patiño Rojas. Created on 6/1/26.

import SwiftUI

fileprivate typealias MoviesLoader = () async throws -> [Movie]

fileprivate protocol MoviesLoadingView {
    func displayLoading(_ bool: Bool)
}

fileprivate protocol MoviesErrorView {
    func displayError(_ bool: Bool)
}

fileprivate protocol MoviesView {
    func displayMovies(_ movies: [Movie])
    func displayEmpty()
}

@MainActor
fileprivate class MovieListPresenter {
    let loader: MoviesLoader
    let moviesView: MoviesView
    let loadingView: MoviesLoadingView
    let errorView: MoviesErrorView
    
    init(loader: @escaping MoviesLoader, moviesView: MoviesView, loadingView: MoviesLoadingView, errorView: MoviesErrorView) {
        self.loader = loader
        self.moviesView = moviesView
        self.loadingView = loadingView
        self.errorView = errorView
    }
    
    func load() async {
        loadingView.displayLoading(true)
        
        do {
            let movies = try await loader()
            movies.isEmpty ? moviesView.displayEmpty() : moviesView.displayMovies(movies)
        } catch {
            errorView.displayError(true)
        }
    }
    
    func refresh() {
        errorView.displayError(false)
    }
}

@Observable @MainActor
fileprivate class MovieListStore: MovieList.Model {
    private(set) var movies = [Movie]()
    private(set) var showLoading = true
    private(set) var showEmpty = false
    private(set) var showError = false
    
    let loader: MoviesLoader
    
    init(loader: @escaping MoviesLoader) {
        self.loader = loader
    }
    
    func load() async {
        do {
            displayMovies(try await loader())
        } catch {
            displayError()
        }
    }
    
    func refresh() async {
        dismissError()
        await load()
    }
    
    func displayError() {
        showLoading = false
        showError = true
    }
    
    func dismissError() {
        showError = false
    }
    
    func displayMovies(_ movies: [Movie]) {
        self.movies = movies
        showLoading = false
        showEmpty = movies.isEmpty
        showError = false
    }
}

fileprivate struct MovieListController: View {
    @State private var store: MovieListStore
    
    init(loader: @escaping () async throws -> [Movie]) {
        store = .init(loader: loader)
    }
    
    var body: some View {
        MovieList(model: store, onErrorButtonTap: { store.dismissError() })
            .task(store.load)
            .refreshable(action: store.refresh)
    }
}



fileprivate struct MovieList: View {
    let model: Model
    let onErrorButtonTap: () -> Void
    var body: some View {
        List(model.movies, rowContent: Cell.init)
            .overlay { if model.showLoading { ProgressView() } }
            .overlay { if model.showEmpty   { EmptyMoviesView() } }
            .toolbar { if model.showError   { ErrorButton(action: onErrorButtonTap) } }
    }
}

extension MovieList {
    protocol Model {
        var movies: [Movie] { get }
        var showLoading: Bool { get }
        var showEmpty: Bool { get }
        var showError: Bool { get }
    }
}


#Preview("Controller") {
    var shouldFail = false
    MovieListController {
        defer { shouldFail.toggle() }
        try await Task.sleep(for: .seconds(1.5))
        if shouldFail {
            throw anyError()
        } else {
            return [mockMovie(), mockMovie()]
        }
    }
}

#Preview("Loading") {
    let store = MovieListStore {[]}
    MovieList(model: store) {}
}

#Preview("Loaded") {
    let store = MovieListStore {[]}
    store.displayMovies([mockMovie()])
    return MovieList(model: store) {}
}

#Preview("Empty") {
    let store = MovieListStore {[]}
    store.displayMovies([])
    return MovieList(model: store) {}
}

#Preview("Error") {
    @Previewable @State var store: MovieListStore = {
        let store = MovieListStore {[]}
        store.displayError()
        return store
    }()
    
    return MovieList(model: store) { store.dismissError() }
}

#Preview("Loaded + Error") {
    @Previewable @State var store: MovieListStore = {
        let store = MovieListStore {[]}
        store.displayMovies([mockMovie()])
        store.displayError()
        return store
    }()
  
    return MovieList(model: store)  { store.dismissError() }
}


#Preview("Empty + Error") {
    @Previewable @State var store: MovieListStore = {
        let store = MovieListStore {[]}
        store.displayMovies([])
        store.displayError()
        return store
    }()
  
    return MovieList(model: store)  { store.dismissError() }
}
