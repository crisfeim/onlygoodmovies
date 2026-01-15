// © 2026  Cristian Felipe Patiño Rojas. Created on 13/1/26.

import Movies
import MoviesiOSUI
import SwiftUI

public struct MoviesUIComposer: View {
    @State var state = MoviesState()
    
    let loader: MoviesLoader
   
    var useCase: MoviesLogic {
        .init(state: $state, loader: loader)
    }
    
    public init(loader: @escaping MoviesLoader) {
        self.loader = loader
    }
    
    public var body: some View {
        MovieList(state: $state)
            .environment(\.reload, useCase.refresh)
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
   
   
    MoviesUIComposer { @MainActor in
        try await Task.sleep(for: .seconds(1.5))

        if shouldFail {
            shouldFail = false
            throw NSError(domain: "any-error", code: 0)
        } else {
            shouldFail = true
            return [movie, movie]
        }
    }
}
