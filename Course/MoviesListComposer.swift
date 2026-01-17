// © 2026  Cristian Felipe Patiño Rojas. Created on 13/1/26.

import Movies
import SwiftUI
import MoviesiOSUI

struct MoviesListComposer<AsyncThumbnail: View>: View {
    @State var state = MoviesState()
    
    let loader: MoviesLoader
    let cell: (Movie) -> MovieCell<AsyncThumbnail>
    
    var logic: MoviesLogic {
        .init($state, loader: loader)
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
        MovieList(state: $state, cell: cell)
        .environment(\.reload, logic.refresh)
        .task(logic.load)
    }
}


// Previews

#Preview("App") {
    var shouldFail = false
    let movie = Movie(
        id: "17",
        title: "The Passion of the Christ",
        posterURL: "https://crisfe.im/apis/only-good-movies/passionofchrist.png",
        releaseYear: 2004
    )
   
    MoviesListComposer(
        loader: {@MainActor in
        try await Task.sleep(for: .seconds(1.5))
        
        if shouldFail {
            shouldFail = false
            throw NSError(domain: "any-error", code: 0)
        } else {
            shouldFail = true
            return [movie, movie]
        }
        },
        thumbnailProvider: AsyncImage<MovieThumbnail>.make
    )
}
