// © 2026  Cristian Felipe Patiño Rojas. Created on 3/1/26.

@testable import Course
import XCTest
import SwiftUI
import Movies

@MainActor
final class MovieListComposerTests: XCTestCase {
    func test_moviesAreLoadedAfterRendered() async throws {
        let expectedMovies = [anyMovie()]
        let composer = MovieListComposer<Text>(loader: expectedMovies.stream) { _ in Text("any thumbnail") }
        TestApp.shared.setView(composer)
        
        for await (index, view) in MovieListComposer<Text>.bodyEvaluations().prefix(2).timeout(1) {
            switch index {
            case 0: XCTAssertEqual(view.state.movies, [])
            case 1: XCTAssertEqual(view.state.movies, expectedMovies)
            default: break
            }
        }
    }
}

fileprivate extension Array where Element: Sendable {
    var stream: @Sendable () -> AsyncThrowingStream<Element, Error> {
        {
            AsyncThrowingStream { continuation in
                for item in self {
                    continuation.yield(item)
                }
                continuation.finish()
            }
        }
    }
}

fileprivate func anyMovie() -> Movie {
    Movie(id: "0", title: "some title", posterURL: "someposterurl", releaseYear: 2000)
}

fileprivate struct Wrapper<Element, Failure>: @unchecked Sendable {
    let value: any AsyncSequence<Element, Failure>
}

fileprivate extension AsyncSequence where Element: Sendable {
    func timeout( _ seconds: TimeInterval, file: StaticString = #filePath, line: UInt = #line) -> AsyncStream<Element> {
        let wrapped = Wrapper(value: self)
        return AsyncStream { continuation in
            
            let iterationTask = Task { @Sendable in
                do {
                    for try await element in wrapped.value {
                        continuation.yield(element)
                    }
                    continuation.finish()
                } catch {
                    continuation.finish()
                }
            }
            
            let timeoutTask = Task { [iterationTask] in
                try? await Task.sleep(for: .seconds(seconds))
                if !Task.isCancelled {
                    XCTFail("Timeout reached", file: file, line: line)
                    iterationTask.cancel()
                    continuation.finish()
                }
            }
            
            continuation.onTermination = { _ in
                iterationTask.cancel()
                timeoutTask.cancel()
            }
        }
    }
}
