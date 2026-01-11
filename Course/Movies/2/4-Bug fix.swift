// © 2026  Cristian Felipe Patiño Rojas. Created on 6/1/26.

import SwiftUI

@MainActor // <- needed?
fileprivate struct MovieListStore: MovieList.Model {
    private(set) var movies = [Movie]()
    private(set) var showLoading = true
    private(set) var showEmpty = false
    private(set) var showError = false
    
    mutating func displayError() {
        showLoading = false
        showError = true
    }
    
    mutating func dismissError() {
        showError = false
    }
    
    mutating func displayMovies(_ movies: [Movie]) {
        self.movies = movies
        showLoading = false
        showEmpty = movies.isEmpty
        showError = false
    }
}

fileprivate struct MovieListController: View {
    @State var store = MovieListStore()
    
    let loader: () async throws -> [Movie]
    var body: some View {
        MovieList(
            model: store,
            onErrorButtonTap: { store.dismissError() },
            onRefresh: refresh
        )
        .task(load)
    }
    
    func load() async {
        do {
            store.displayMovies(try await loader())
        } catch {
            store.displayError()
        }
    }
    
    func refresh() async {
        store.dismissError()
        await load()
    }
}



fileprivate struct MovieList: View {
    let model: Model
    let onErrorButtonTap: () -> Void
    let onRefresh: @Sendable () async -> Void
    var body: some View {
        if model.showLoading {
            ProgressView()
        } else {
            List(model.movies, rowContent: Cell.init)
                .overlay { if model.showEmpty   { EmptyMoviesView() } }
                .toolbar { if model.showError   { ErrorButton(action: onErrorButtonTap) } }
                .refreshable(action: onRefresh)
        }
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
        try await Task.sleep(for: .seconds(2))
        if shouldFail {
            throw anyError()
        } else {
            return [mockMovie(), mockMovie()]
        }
    }
}


#Preview("Loading") {
    let store = MovieListStore()
    return MovieList(model: store) {} onRefresh: {}

}

#Preview("Loaded") {
    var store = MovieListStore()
    store.displayMovies([mockMovie()])
    return MovieList(model: store) {} onRefresh: {}
}

#Preview("Empty") {
    var store = MovieListStore()
    store.displayMovies([])
    return MovieList(model: store) {} onRefresh: {}
}

#Preview("Error") {
    @Previewable @State var store: MovieListStore = {
        var store = MovieListStore()
        store.displayError()
        return store
    }()
    
    return MovieList(model: store) {} onRefresh: {}
}

#Preview("Loaded + Error") {
    @Previewable @State var store: MovieListStore = {
        var store = MovieListStore()
        store.displayMovies([mockMovie()])
        store.displayError()
        return store
    }()
  
    return MovieList(model: store) {} onRefresh: {}
}


#Preview("Empty + Error") {
    @Previewable @State var store: MovieListStore = {
        var store = MovieListStore()
        store.displayMovies([])
        store.displayError()
        return store
    }()
  
    return MovieList(model: store) {} onRefresh: {}
}
