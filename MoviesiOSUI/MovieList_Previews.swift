// © 2026  Cristian Felipe Patiño Rojas. Created on 18/1/26.

import Movies
import SwiftUI

#Preview("Loading") {
    MovieList<MovieThumbnail>(state: .constant(.loading), config: .loading)
}

#Preview("Loaded") {
    MovieList<MovieThumbnail>(state: .constant(.loaded), config: .idle)
}

#Preview("Empty") {
    MovieList<MovieThumbnail>(state: .constant(.empty), config: .idle)
}

#Preview("Error") {
    @Previewable @State var state = MoviesState.error
    MovieList<MovieThumbnail>(state: $state, config: .idle)
}

#Preview("Loaded + Error") {
    @Previewable @State var state = MoviesState.loadedWithError
    MovieList<MovieThumbnail>(state: $state, config: .idle)
}


#if DEBUG
fileprivate extension MoviesState {
    static var loading: Self {
        .init(
            movies: [mockMovie(), mockMovie()],
            showLoading: true,
            showError: false,
            showEmpty: false
        )
    }
    
    static var loaded: Self {
        .init(
            movies: [mockMovie(), mockMovie()],
            showLoading: false,
            showError: false,
            showEmpty: false
        )
    }
    
    static var loadedWithError: Self {
        .init(
            movies: [mockMovie(), mockMovie()],
            showLoading: false,
            showError: true,
            showEmpty: false
        )
    }
    
    static var error: Self {
        .init(
            movies: [],
            showLoading: false,
            showError: true,
            showEmpty: false
        )
    }
    
    static var empty: Self {
        .init(
            movies: [],
            showLoading: false,
            showError: false,
            showEmpty: true
        )
    }
}
#endif

