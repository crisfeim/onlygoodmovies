// © 2026  Cristian Felipe Patiño Rojas. Created on 13/1/26.

import SwiftUI
import Movies

public struct MovieList<Thumbnail: View>: View {
    public typealias Cell = (Movie) -> MovieCell<Thumbnail>
    @Binding var state: MoviesState
    @Binding var config: MoviesConfig
    @Environment(\.reload) private var reload
    let cell: Cell

    public init(state: Binding<MoviesState>, config: Binding<MoviesConfig>, cell: @escaping Cell) {
        self._state = state
        self._config = config
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
        .toolbar { if state.showError {ErrorButton{ state.showError = false}} }
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

struct Shimmer: ViewModifier {
   @State private var isInitialState: Bool = true
   
   func body(content: Content) -> some View {
       content
           .mask {
               LinearGradient(
                gradient: .init(colors: [Color.white.opacity(0.5), Color.white, Color.white.opacity(0.5)]),
                   startPoint: (isInitialState ? .init(x: -1, y: -1) : .init(x: 1, y: 1)),
                   endPoint: (isInitialState ? .init(x: 0, y: 0) : .init(x: 2, y: 2))
               )
               .animation(.linear(duration: 1.5).delay(0.25).repeatForever(autoreverses: false), value: isInitialState)
               .onAppear() {
                   isInitialState = false
               }
           }
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
            movies: [mockMovie(), mockMovie()],
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
    @Previewable @State var state = MoviesState.loading()
    MovieList(state: $state, config: .constant(.loading), cell: MovieList<MovieThumbnail>.defaultCell)
}

#Preview("Loaded") {
    @Previewable @State var state = MoviesState.loaded()
    MovieList(state: $state, config: .constant(.idle), cell: MovieList<MovieThumbnail>.defaultCell)
}

#Preview("Empty") {
    @Previewable @State var state = MoviesState.empty()
    MovieList(state: $state, config: .constant(.idle), cell: MovieList<MovieThumbnail>.defaultCell)
}

#Preview("Error") {
    @Previewable @State var state = MoviesState.error()
    MovieList(state: $state, config: .constant(.idle), cell: MovieList<MovieThumbnail>.defaultCell)
}

#Preview("Loaded + Error") {
    @Previewable @State var state = MoviesState.loadedWithError()
    MovieList(state: $state, config: .constant(.idle), cell: MovieList<MovieThumbnail>.defaultCell)
}

