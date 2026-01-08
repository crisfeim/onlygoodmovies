// © 2026  Cristian Felipe Patiño Rojas. Created on 6/1/26.

import SwiftUI

struct LoadableModifier: ViewModifier {
    @MainActor
    @Observable final class Store {
        @ObservationIgnored
        var isFirstLoad = true
        var isLoading = true
        
        private let action: () async -> Void
        
        init(action: @escaping () async -> Void) {
            self.action = action
        }
        
        func load() async {
            guard isFirstLoad else { return }
            isFirstLoad = false
            await action()
            isLoading = false
        }
    }
    
    @State private var store: Store
    init(action: @escaping () async -> Void) {
        self.store = .init(action: action)
    }
    func body(content: Content) -> some View {
        content.task(store.load)
        .overlay {
            if store.isLoading {
                ProgressView().controlSize(.large)
            }
        }
    }
}

extension View {
    func loadable(action: @escaping () async -> Void) -> some View {
        self.modifier(LoadableModifier(action: action))
    }
}


fileprivate struct MovieListStore: MovieList.Model {
    private(set) var movies = [Movie]()
    private(set) var showEmpty = false
    private(set) var showError = false
    
    mutating func displayError() {
        showError = true
    }
    
    mutating func dismissError() {
        showError = false
    }
    
    mutating func displayMovies(_ movies: [Movie]) {
        self.movies = movies
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
        MovieList(model: store, onErrorButtonTap: { store.dismissError() })
            .loadable(action: load)
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
    let model: Model
    let onErrorButtonTap: () -> Void
    var body: some View {
        List(model.movies, rowContent: Cell.init)
            .overlay { if model.showEmpty  { EmptyMoviesView() } }
            .toolbar { if model.showError  { ErrorButton(action: onErrorButtonTap) } }
    }
}

extension MovieList {
    protocol Model {
        var movies: [Movie] { get }
        var showEmpty: Bool { get }
        var showError: Bool { get }
    }
}


#Preview("Controller") {
    var shouldFail = false
    MovieListController {
        try await Task.sleep(for: .seconds(1))
        
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

#Preview("Loaded") {
    var store = MovieListStore()
    store.displayMovies([mockMovie()])
    return MovieList(model: store) {}
}

#Preview("Empty") {
    var store = MovieListStore()
    store.displayMovies([])
    return MovieList(model: store) {}
}

#Preview("Error") {
    @Previewable @State var store: MovieListStore = {
        var store = MovieListStore()
        store.displayError()
        return store
    }()
    
    return MovieList(model: store) { store.dismissError() }
}

#Preview("Loaded + Error") {
    @Previewable @State var store: MovieListStore = {
        var store = MovieListStore()
        store.displayMovies([mockMovie()])
        store.displayError()
        return store
    }()
  
    return MovieList(model: store)  { store.dismissError() }
}


#Preview("Empty + Error") {
    @Previewable @State var store: MovieListStore = {
        var store = MovieListStore()
        store.displayMovies([])
        store.displayError()
        return store
    }()
  
    return MovieList(model: store)  { store.dismissError() }
}
