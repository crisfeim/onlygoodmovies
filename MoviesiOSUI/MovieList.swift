// © 2026  Cristian Felipe Patiño Rojas. Created on 13/1/26.

import Movies
import SwiftUI

public struct MovieList<Thumbnail: View>: View {
    public typealias Row = (Movie) -> MovieRow<Thumbnail>
    
    @Binding var state: MoviesState
    @Environment(\.reload) private var reload
    
    let config: MoviesConfig
    let row: Row

    public init(state: Binding<MoviesState>, config: MoviesConfig, row: @escaping Row) {
        self._state = state
        self.config = config
        self.row = row
    }

    public var body: some View {
        List(state.movies) { movie in
            row(movie)
                .redacted(reason: config.reason)
                .modifier(config.modifier)
        }
        .scrollIndicators(.hidden)
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
        self.row = Self.row(_:)
    }
    
    static func row(_ movie: Movie) -> MovieRow<Thumbnail> {
        MovieRow(movie: movie) { _ in
            MovieThumbnail(phase: .empty)
        }
    }
}
