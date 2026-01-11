// © 2026  Cristian Felipe Patiño Rojas. Created on 6/1/26.

import SwiftUI

fileprivate struct MovieListStore {
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
    
    mutating func refresh() {
        showError = false
    }
}
fileprivate struct MovieListController: View {
    @State var store = MovieListStore()
    
    let loader: () async throws -> [Movie]
    var body: some View {
        MovieList(
            items: store.movies,
            isLoading: store.showLoading,
            isEmpty: store.showEmpty,
            showError: store.showError,
            onErrorButtonTap: { store.dismissError() }
        )
        .task(load)
        .refreshable(action: refresh)
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
    let items: [Movie]
    let isLoading: Bool
    let isEmpty: Bool
    let showError: Bool
    let onErrorButtonTap: () -> Void
    var body: some View {
        List(items, rowContent: Cell.init)
        .overlay { if isLoading { ProgressView() } }
        .overlay { if isEmpty   { EmptyMoviesView() } }
        .toolbar { if showError  { ErrorButton(action: onErrorButtonTap) } }
    }
}

#Preview("Controller", traits: .sizeThatFitsLayout) {
    var shouldFail = false
    MovieListController {
        try await Task.sleep(for: .seconds(2))
        
        if shouldFail {
            print("should fail")
            shouldFail = false
            throw anyError()
        } else {
            print("should not fail")
            shouldFail = true
            return [mockMovie(), mockMovie()]
        }
    }
}

#Preview("Loading") {
    let store = MovieListStore()
    MovieList(
        items: store.movies,
        isLoading: store.showLoading,
        isEmpty: store.showEmpty,
        showError: store.showEmpty,
        onErrorButtonTap: {}
    )
}

// Este estado ya no es necesario de checkear
//#Preview("Loading - ShowError: true") {
//    let store = MovieListStore(hasError: true)
//    MovieList(
//        movies: store.items,
//        isLoading: store.isLoading,
//        isEmpty: store.isEmpty,
//        hasError: store.hasError,
//        onErrorButtonTap: {}
//    )
//}


#Preview("Loaded") {
    var store = MovieListStore()
    store.displayMovies([mockMovie()])
    return MovieList(
        items: store.movies,
        isLoading: store.showLoading,
        isEmpty: store.showError,
        showError: store.showLoading,
        onErrorButtonTap: {}
    )
}

#Preview("Empty") {
    var store = MovieListStore()
    store.displayMovies([])
    return MovieList(
        items: store.movies,
        isLoading: store.showLoading,
        isEmpty: store.showEmpty,
        showError: store.showError,
        onErrorButtonTap: {}
    )
}

#Preview("Error") {
    @Previewable @State var store: MovieListStore = {
        var store = MovieListStore()
        store.displayError()
        return store
    }()
    
    return MovieList(
        items: store.movies,
        isLoading: store.showLoading,
        isEmpty: store.showEmpty,
        showError: store.showError,
        onErrorButtonTap: { store.dismissError() }
    )
}

#Preview("Loaded + Error") {
    @Previewable @State var store: MovieListStore = {
        var store = MovieListStore()
        store.displayMovies([mockMovie()])
        store.displayError()
        return store
    }()
  
    return MovieList(
        items: store.movies,
        isLoading: store.showLoading,
        isEmpty: store.showEmpty,
        showError: store.showError,
        onErrorButtonTap: { store.dismissError() }
    )
}


#Preview("Empty + Error") {
    @Previewable @State var store: MovieListStore = {
        var store = MovieListStore()
        store.displayMovies([])
        store.displayError()
        return store
    }()
  
    return MovieList(
        items: store.movies,
        isLoading: store.showLoading,
        isEmpty: store.showEmpty,
        showError: store.showError,
        onErrorButtonTap: { store.dismissError() }
    )
}
