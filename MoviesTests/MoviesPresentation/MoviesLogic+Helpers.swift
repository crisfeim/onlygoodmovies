// © 2026  Cristian Felipe Patiño Rojas. Created on 18/1/26.

import XCTest
import Movies

func anyLoader() -> MoviesLoader {{[]}}

func mockMovie() -> Movie {
    Movie(id: "id", title: "title", posterURL: "potter_url", releaseYear: 2020)
}

import SwiftUI

class BindingSpy {
    var capturedStates: [MoviesState] = []
    private let initState: MoviesState
    
    init(initState: MoviesState = .init()) {
        self.initState = initState
    }
    
    @MainActor
    var binding: Binding<MoviesState> {
        .init(get: { self.initState }, set: { self.capturedStates.append($0) })
    }
}
