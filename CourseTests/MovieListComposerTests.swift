// © 2026  Cristian Felipe Patiño Rojas. Created on 3/1/26.

@testable import Course
import XCTest
import SwiftUI
import Movies

@MainActor
final class MovieListComposerTests: XCTestCase {
    func test_moviesAreLoadedAfterRendered() async {
        let expectedMovies = [anyMovie()]
        
        let loader: MoviesLoader = { @Sendable in
            AsyncThrowingStream { continuation in
                for movie in expectedMovies {
                    continuation.yield(movie)
                }
                continuation.finish()
            }
        }
        
        let composer = MovieListComposer(loader: loader) { _ in Text("any thumbnail") }
        TestApp.shared.setView(composer)
        
        for await (index, view) in MovieListComposer<Text>.bodyEvaluations().prefix(2) {
            switch index {
            case 0: XCTAssertEqual(view.state.movies, [])
            case 1: XCTAssertEqual(view.state.movies, expectedMovies)
            default: break
            }
        }
    }
}

fileprivate func anyMovie() -> Movie {
    Movie(id: "0", title: "some title", posterURL: "someposterurl", releaseYear: 2000)
}
