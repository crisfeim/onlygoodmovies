// © 2026  Cristian Felipe Patiño Rojas. Created on 11/1/26.

import SwiftUI
fileprivate struct Inject<Model, Content: View>: View {
    @State var state: Model
    let content: (Binding<Model>) -> Content
    
    init(_ state: Model, content: @escaping (Binding<Model>) -> Content) {
        self.state = state
        self.content = content
    }
    
    var body: some View { content($state) }
}


fileprivate struct MovieList: View {
    let model: Model
    let onErrorButtonTap: () -> Void

    var body: some View {
        List(model.movies ?? [], rowContent: Cell.init)
        .overlay { if model.isLoading { ProgressView() } }
        .overlay { if model.showEmpty { EmptyMoviesView() } }
        .toolbar { if model.showError { ErrorButton(action: onErrorButtonTap) } }
    }
}

extension MovieList {
    struct Model {
        var movies: [Movie]?
        var showError = false
        
        var isLoading: Bool {
            movies == nil
        }
        var showEmpty: Bool {
            guard let movies = movies else { return false }
            return movies.isEmpty
        }
    }
}

fileprivate struct MoviesLogic: Sendable {
    @Binding var state: MovieList.Model
    let loader: @Sendable () async throws -> [Movie]
    
    var load: @Sendable () async -> Void {{
        do    { state.movies = try await loader() }
        catch { state.showError = true            }
    }}
  
    var refresh: @Sendable () async -> Void {{
        state.showError = false
        await load()
    }}
    
    var dismissError: () -> Void {
        {state.showError = false}
    }
}

fileprivate struct MovieListController: View {
    @Binding var state: MovieList.Model
    let loader: @Sendable () async throws -> [Movie]
    var logic: MoviesLogic { .init(state: $state, loader: loader) }
    
    var body: some View {
        MovieList(model: state) { state.showError = false }
            .task(logic.load)
            .refreshable(action: logic.refresh)
    }
}

#Preview {
   Inject(.init()) {
        MovieListController(state: $0) {
            try? await Task.sleep(for: .seconds(1.5))
            return [mockMovie(), mockMovie()]
        }
    }
}
