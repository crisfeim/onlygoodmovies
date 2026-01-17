// © 2026  Cristian Felipe Patiño Rojas. Created on 13/1/26.

import SwiftUI
import Movies

struct MovieList<Thumbnail: View>: View {
    @Binding var state: MoviesState
    @Environment(\.reload) var reload
    let cell: (Movie) -> MovieCell<Thumbnail>

    var body: some View {
        List(state.movies, rowContent: cell)
        .refreshable { await reload() }
        .overlay { if state.showLoading { ProgressView() } }
        .overlay { if state.showEmpty { EmptyMoviesView() } }
        .toolbar { if state.showError { ErrorButton { state.showError = false } } }
    }
}

extension EnvironmentValues {
    @Entry var reload: () async -> Void = {}
}

#if DEBUG
fileprivate extension MoviesState {
    static func loading() -> Self {
        .init(
            movies: [],
            showLoading: true,
            showError: false,
            showEmpty: false
        )
    }
    
    static func loaded() -> Self {
        .init(
            movies: [mockMovie(), mockMovie()],
            showLoading: false,
            showError: false,
            showEmpty: false
        )
    }
    
    static func loadedWithError() -> Self {
        .init(
            movies: [mockMovie(), mockMovie()],
            showLoading: false,
            showError: true,
            showEmpty: false
        )
    }
    
    static func error() -> Self {
        .init(
            movies: [],
            showLoading: false,
            showError: true,
            showEmpty: false
        )
    }
    
    static func empty() -> Self {
        .init(
            movies: [],
            showLoading: false,
            showError: false,
            showEmpty: true
        )
    }
}
#endif


#Preview("Loading") {
    @Previewable @State var state = MoviesState()
    MovieList(state: $state, cell: MovieCell<AsyncImage<MovieThumbnail>>.make)
}

#Preview("Loaded") {
    @Previewable @State var state = MoviesState.loaded()
    MovieList(state: $state, cell: MovieCell<AsyncImage<MovieThumbnail>>.make)
}

#Preview("Empty") {
    @Previewable @State var state = MoviesState.empty()
    MovieList(state: $state, cell: MovieCell<AsyncImage<MovieThumbnail>>.make)
}

#Preview("Error") {
    @Previewable @State var state = MoviesState.error()
    MovieList(state: $state, cell: MovieCell<AsyncImage<MovieThumbnail>>.make)
}

#Preview("Loaded + Error") {
    @Previewable @State var state = MoviesState.loadedWithError()
    MovieList(state: $state, cell: MovieCell<AsyncImage<MovieThumbnail>>.make)
}

