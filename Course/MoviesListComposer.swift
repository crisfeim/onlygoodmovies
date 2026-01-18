// © 2026  Cristian Felipe Patiño Rojas. Created on 13/1/26.

import Movies
import SwiftUI
import MoviesiOSUI

struct MoviesListComposer<AsyncThumbnail: View>: View {
    @State var state  = MoviesState()
    @State var config = MoviesConfig()
    
    let loader: MoviesLoader
    let cell: (Movie) -> MovieCell<AsyncThumbnail>
    
    var logic: MoviesLogic {
        .init($state, $config, loader: loader)
    }
    
    init(
        state: MoviesState = MoviesState(),
        loader: @escaping MoviesLoader,
        thumbnailProvider: @escaping (URL?) -> AsyncThumbnail,
    ) {
        self.state = state
        self.loader = loader
        self.cell =  { MovieCell(movie: $0, thumbnailProvider: thumbnailProvider) }
    }
    
    var body: some View {
        MovieList(state: $state, config: $config, cell: cell)
        .environment(\.reload, logic.refresh)
        .task(logic.load)
    }
}
