// © 2026  Cristian Felipe Patiño Rojas. Created on 13/1/26.

import Movies
import SwiftUI

public struct MovieList<Thumbnail: View>: View {
    public typealias Cell = (Movie) -> MovieCell<Thumbnail>
    
    @Binding var state: MoviesState
    @Environment(\.reload) private var reload
    
    let config: MoviesConfig
    let cell: Cell

    public init(state: Binding<MoviesState>, config: MoviesConfig, cell: @escaping Cell) {
        self._state = state
        self.config = config
        self.cell = cell
    }

    public var body: some View {
        List(state.movies) { movie in
            cell(movie)
                .redacted(reason: config.reason)
                .modifier(config.modifier)
        }
        .disabled(config.listDisabled)
        .refreshable { await reload() }
        .overlay { if state.showEmpty {EmptyMoviesView()} }
        .toolbar { if state.showError {ErrorButton{state.showError = false}} }
    }
}

extension Modifier: @retroactive ViewModifier {
    public func body(content: Content) -> some View {
        switch self {
        case .shimmer: content.modifier(Shimmer())
        default: content
        }
    }
}

public extension EnvironmentValues {
    @Entry var reload: () async -> Void = {}
}

extension MovieList<MovieThumbnail> {
    init(state: Binding<MoviesState>, config: MoviesConfig) {
        self._state = state
        self.config = config
        self.cell = Self.cell(_:)
    }
    
    static func cell(_ movie: Movie) -> MovieCell<Thumbnail> {
        MovieCell(movie: movie) { _ in
            MovieThumbnail(phase: .empty)
        }
    }
}
