// © 2026  Cristian Felipe Patiño Rojas. Created on 13/1/26.

import Movies
import MoviesiOSUI
import SwiftUI

struct MoviesListComposer<Thumbnail: View>: View {
    @State var state  = MoviesState()
    @State var config = MoviesConfig()
    
    let loader: MoviesLoader
    let row: (Movie) -> MovieRow<Thumbnail>
    
    var presenter: MoviesPresenter {
        .init($state, $config, loader: loader)
    }
    
    init(
        loader: @escaping MoviesLoader,
        thumbnail: @escaping (URL?) -> Thumbnail,
    ) {
        self.loader = loader
        self.row =  { MovieRow(movie: $0, thumbnail: thumbnail) }
    }
    
    var body: some View {
        MovieList(state: $state, config: config, row: row)
        .environment(\.reload, presenter.refresh)
        .task(presenter.firstLoad)
    }
}
