// © 2026  Cristian Felipe Patiño Rojas. Created on 13/1/26.

import Movies
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
    MoviesUIComposer {
        try await Task.sleep(for: .seconds(1.5))

        if shouldFail {
            print("should fail")
            shouldFail = false
            throw anyError()
        } else {
            print("should not fail")
            shouldFail = true
            return [mockMovie(), mockMovie()]
        }
    }
}
