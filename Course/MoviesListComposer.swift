// © 2026  Cristian Felipe Patiño Rojas. Created on 13/1/26.

import Movies
import MoviesiOSUI
import SwiftUI

struct MoviesListComposer<Thumbnail: View>: View {
    @State var state  = MoviesState()
    @State var config = MoviesConfig()
    
    let loader: MoviesLoader
    let cell: (Movie) -> MovieCell<Thumbnail>
    
    var presenter: MoviesPresenter {
        .init($state, $config, loader: loader)
    }
    
    init(
        loader: @escaping MoviesLoader,
        thumbnailProvider: @escaping (URL?) -> Thumbnail,
    ) {
        self.loader = loader
        self.cell =  { MovieCell(movie: $0, thumbnailProvider: thumbnailProvider) }
    }
    
    var body: some View {
        MovieList(state: $state, config: config, cell: cell)
        .environment(\.reload, presenter.refresh)
        .task(presenter.firstLoad)
    }
}
