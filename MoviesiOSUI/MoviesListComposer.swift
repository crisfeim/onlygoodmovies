// © 2026  Cristian Felipe Patiño Rojas. Created on 13/1/26.

import Movies
import SwiftUI
import Movies

public struct MoviesListComposer<Cell: View>: View {
    @State var state = MoviesState()
    
    let loader: MoviesLoader
    let imagesLoader: ImagesLoader
    let imagesStore: ImagesStore
    let cellProvider: (Movie) -> Cell
    
    var logic: MoviesLogic {
        .init($state, loader: loader)
    }
    
    public init(
        state: MoviesState = MoviesState(),
        loader: @escaping MoviesLoader,
        cellProvider: @escaping (Movie) -> Cell,
        imagesLoader: @escaping ImagesLoader,
        imagesStore: @escaping ImagesStore
    ) {
        self.state = state
        self.loader = loader
        self.cellProvider = cellProvider
        self.imagesLoader = imagesLoader
        self.imagesStore = imagesStore
    }
    
    public var body: some View {
        MovieList(state: $state, cell: cellProvider)
            .environment(\.reload, logic.refresh)
            .environment(\.imagesLoader, imagesLoader)
            .environment(\.imagesStore, imagesStore)
            .task(logic.load)
    }
}

extension MovieCell<ResourceImage<MovieThumbnail>> {
    static func `default`(_ movie: Movie) -> Self {
        MovieCell(movie: movie) {
            ResourceImage(url: $0, content: MovieThumbnail.init)
        }
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
        cellProvider: MovieCell<AsyncImage<MovieThumbnail>>.default,
        imagesLoader: {_ in nil },
        imagesStore: { _ in nil })
}
