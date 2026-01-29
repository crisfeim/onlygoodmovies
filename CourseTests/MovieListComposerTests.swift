// © 2026  Cristian Felipe Patiño Rojas. Created on 3/1/26.

@testable import Course
import XCTest
import SwiftUI
import Movies

@MainActor
final class MovieListComposerTests: XCTestCase {
    func test_moviesAreLoadedAfterRendered() async throws {
        let expectedMovies = [anyMovie()]
        
        let loader: MoviesLoader = { @Sendable in
            AsyncThrowingStream { continuation in
                for movie in expectedMovies {
                    continuation.yield(movie)
                }
                continuation.finish()
            }
        }
//        
        let composer = MovieListComposer(loader: loader) { _ in Text("any thumbnail") }
        TestApp.shared.setView(composer)
        
        for try await (index, view) in MovieListComposer<Text>.bodyEvaluations().prefix(2).timeout(1) {
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

private struct Wrapper<Element, Failure>: @unchecked Sendable {
    let value: any AsyncSequence<Element, Failure>
}

extension AsyncSequence where Element: Sendable {
    func timeout(_ seconds: TimeInterval) -> AsyncThrowingStream<Element, Error> {
        let wrapped = Wrapper(value: self)
        return AsyncThrowingStream { continuation in
            let timeoutTask = Task {
                try? await Task.sleep(for: .seconds(seconds))
                continuation.finish(throwing: CancellationError())
            }
            
            Task { @Sendable in
                do {
                    for try await element in wrapped.value {
                        continuation.yield(element)
                    }
                    timeoutTask.cancel()
                    continuation.finish()
                } catch {
                    timeoutTask.cancel()
                    continuation.finish(throwing: error)
                }
            }
            
            continuation.onTermination = { _ in
                timeoutTask.cancel()
            }
        }
    }
}
