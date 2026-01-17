// © 2026  Cristian Felipe Patiño Rojas. Created on 13/1/26.

import SwiftUI
import Movies

public struct MovieList<Thumbnail: View>: View {
    public typealias Cell = (Movie) -> MovieCell<Thumbnail>
    @Binding var state: MoviesState
    @Environment(\.reload) private var reload
    let cell: Cell

    public init(state: Binding<MoviesState>, cell: @escaping Cell) {
        self._state = state
        self.cell = cell
    }

    public var body: some View {
        List(state.movies, rowContent: cell)
        .refreshable { await reload() }
        .overlay { if state.showLoading { ProgressView() } }
        .overlay { if state.showEmpty { EmptyMoviesView() } }
        .toolbar { if state.showError { ErrorButton { state.showError = false } } }
    }
}

extension MovieList<MovieThumbnail> {
    static func defaultCell(_ movie: Movie) -> MovieCell<Thumbnail> {
        MovieCell(movie: movie) { _ in
            MovieThumbnail(phase: .empty)
        }
    }
}

public extension EnvironmentValues {
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
    MovieList(state: $state, cell: MovieList<MovieThumbnail>.defaultCell)
}

#Preview("Loaded") {
    @Previewable @State var state = MoviesState.loaded()
    MovieList(state: $state, cell: MovieList<MovieThumbnail>.defaultCell)
}

#Preview("Empty") {
    @Previewable @State var state = MoviesState.empty()
    MovieList(state: $state, cell: MovieList<MovieThumbnail>.defaultCell)
}

#Preview("Error") {
    @Previewable @State var state = MoviesState.error()
    MovieList(state: $state, cell: MovieList<MovieThumbnail>.defaultCell)
}

#Preview("Loaded + Error") {
    @Previewable @State var state = MoviesState.loadedWithError()
    MovieList(state: $state, cell: MovieList<MovieThumbnail>.defaultCell)
}

