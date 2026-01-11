// © 2026  Cristian Felipe Patiño Rojas. Created on 6/1/26.

import SwiftUI

fileprivate struct MovieListLogic {
    @Binding var state: MovieList.State
    
    func displayError() {
        state.showLoading = false
        state.showError = true
    }
    
    func dismissError() {
        state.showError = false
    }
    
    func displayMovies(_ movies: [Movie]) {
        state.movies = movies
        state.showLoading = false
        state.showEmpty = movies.isEmpty
        state.showError = false
    }
    
    func refresh() {
        state.showError = false
    }
}

fileprivate struct MovieListLogic_b {
    let get: () -> MovieList.State
    let set: (MovieList.State) -> Void
    
    func displayError() {
        var state = get()
        state.showLoading = false
        state.showError = true
        set(state)
    }
    
    func dismissError() {
        var state = get()
        state.showError = false
        set(state)
    }
    
    func displayMovies(_ movies: [Movie]) {
        var state = get()
        state.movies = movies
        state.showLoading = false
        state.showEmpty = movies.isEmpty
        state.showError = false
        set(state)
    }
    
    func refresh() {
        var state = get()
        state.showError = false
        set(state)
    }
}

@MainActor
fileprivate struct MovieListControllerLogic {
    @Binding var state: MovieList.State
    
    var logic: MovieListLogic_b {
        .init {
            state
        } set: { state in
            self.state = state
        }

    }
    
    let loader: () async throws -> [Movie]
    
    func load() async {
        let logic = MovieListLogic(state: $state)
        do {
            logic.displayMovies(try await loader())
        } catch {
            logic.displayError()
        }
    }
    
    func refresh() async {
        let logic = MovieListLogic(state: $state)
        logic.dismissError()
        await load()
    }
}



fileprivate struct MovieListComposer: View {
    @State var state = MovieList.State()
    let loader: () async throws -> [Movie]
    
    var controller: MovieListControllerLogic {
        .init(state: $state, loader: loader)
    }
    
    var body: some View {
        MovieList(state: $state)
            .task(controller.load)
            .refreshable(action: controller.refresh)
    }
}


fileprivate struct MovieList: View {
    @Binding var state: State
    var body: some View {
        List(state.movies, rowContent: Cell.init)
            .overlay { if state.showLoading { ProgressView() } }
            .overlay { if state.showEmpty
                { EmptyMoviesView() } }
            .toolbar { if state.showError  { ErrorButton { state.showError = false }} }
    }
}

extension MovieList {
    fileprivate struct State {
         var movies = [Movie]()
         var showLoading = true
         var showEmpty = false
         var showError = false
    }
}

#Preview("Controller", traits: .sizeThatFitsLayout) {
    var shouldFail = false
    MovieListComposer {
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
