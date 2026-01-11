// © 2026  Cristian Felipe Patiño Rojas. Created on 6/1/26.

import SwiftUI

fileprivate struct Store {
    var data: [Movie]?
    var showError = false
    
    var movies: [Movie] {
        data ?? []
    }
    var showLoading: Bool {
        data == nil
    }
    var showEmpty: Bool {
        data != nil && (data ?? []).isEmpty
    }
}

fileprivate struct MovieListController: View {
    @State var store = Store()
    let loader: () async throws -> [Movie]
    var body: some View {
        MovieList(
            movies: store.movies,
            showLoading: store.showLoading,
            showEmpty: store.showEmpty,
            showError: store.showError,
            onErrorTap: { store.showError = false }
        )
        .task(load)
        .refreshable(action: refresh)
    }
}

// Control logic
extension MovieListController {
    // Life cycle
    func load() async {
        do { store.data = try await loader() }
        catch { store.showError = true }
    }
    
    func refresh() async {
        store.showError = false
        await load()
    }
}


fileprivate struct MovieList: View {
    let movies: [Movie]
    let showLoading: Bool
    let showEmpty: Bool
    let showError: Bool
    let onErrorTap: () -> Void
    var body: some View {
        List(movies, rowContent: Cell.init)
        .overlay { if showLoading { ProgressView() } }
        .overlay { if showEmpty { EmptyMoviesView() } }
        .toolbar { if showError { ErrorButton(action: onErrorTap) }
        }
    }
}

#Preview("Controller") {
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

//#Preview("Loading") {
//    @Previewable @State var showError = false
//    MovieList(movies: nil, showError: $showError)
//}
//
//#Preview("Loading - ShowError: true") {
//    @Previewable @State var showError = true
//    MovieList(movies: nil, showError: $showError)
//}
//
//#Preview("Loaded") {
//    @Previewable @State var showError = false
//    MovieList(movies: [mockMovie(), mockMovie(), mockMovie()], showError: $showError)
//}
//
//#Preview("Empty") {
//    @Previewable @State var showError = false
//    MovieList(movies: [], showError: $showError)
//}
//
//#Preview("Error") {
//    @Previewable @State var showError = true
//    MovieList(movies: [mockMovie(), mockMovie()], showError: $showError)
//}
//
//#Preview("Loaded + Error") {
//    @Previewable @State var showError = true
//    MovieList(movies: [mockMovie(), mockMovie(), mockMovie()], showError: $showError)
//}
//
//
//#Preview("Empty + Error") {
//    @Previewable @State var showError = true
//    MovieList(movies: [], showError: $showError)
//}
//
