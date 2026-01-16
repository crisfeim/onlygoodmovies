// © 2026  Cristian Felipe Patiño Rojas. Created on 13/1/26.

import Movies
import MoviesiOSUI
import SwiftUI
import Movies

public struct MoviesUIComposer: View {
    @State var state = MoviesState()
    
    let loader: MoviesLoader
    let imagesLoader: ImagesLoader
    let imagesStore: ImagesStore
    
    var useCase: MoviesLogic {
        .init(state: $state, loader: loader)
    }
    
    public var body: some View {
        MovieList(state: $state)
            .environment(\.reload, useCase.refresh)
            .environment(\.imagesLoader, imagesLoader)
            .environment(\.imagesStore, imagesStore)
            .task { await useCase.load() }
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
   
    MoviesUIComposer(
        loader: {@MainActor in
        try await Task.sleep(for: .seconds(1.5))
        
        if shouldFail {
            shouldFail = false
            throw NSError(domain: "any-error", code: 0)
        } else {
            shouldFail = true
            return [movie, movie]
        }
    }, imagesLoader: {_ in nil }, imagesStore: { _ in nil })
}
