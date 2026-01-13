// © 2026  Cristian Felipe Patiño Rojas. Created on 13/1/26.


import SwiftUI
import Core

struct MoviesApp: View {
    @State var state = MoviesState()
    
    let loader: MoviesLoader

    var useCase: MoviesLogic {
        .init(state: $state, loader: loader)
    }
    
    var body: some View {
        MovieList(state: $state)
            .environment(\.reload, useCase.refresh)
            .task { await useCase.load() }
    }
}


// Previews

#Preview("App") {
    var shouldFail = false
    MoviesApp {
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
