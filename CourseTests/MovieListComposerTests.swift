// © 2026  Cristian Felipe Patiño Rojas. Created on 3/1/26.

@testable import Course
import XCTest
import SwiftUI
import Movies

@MainActor
final class MovieListComposerTests: XCTestCase {
    func test_moviesAreLoadedAfterRendered() async throws {
        let expectedMovies = [anyMovie()]
        let composer = makeSUT(loader: expectedMovies.stream)
        TestApp.shared.setView(composer)
        
        for await (index, view) in SUT.bodyEvaluations().prefix(2).timeout(1) {
            switch index {
            case 0: XCTAssertEqual(view.state.movies, [])
            case 1: XCTAssertEqual(view.state.movies, expectedMovies)
            default: break
            }
        }
    }
    
    func test_moviesAreStreamedAfterRendered() async throws {
        let item1 = anyMovie(id: 1)
        let item2 = anyMovie(id: 2)
        let item3 = anyMovie(id: 3)
        let expectedMovies = [item1, item2, item3]
        let composer = makeSUT(loader: expectedMovies.stream)
        ViewStorage.shared.reset()
        TestApp.shared.setView(composer)
        
        for (index, view) in ViewStorage.shared.getHistory(for: MovieListComposer<Text>.self).enumerated() {
            switch index {
            case 0: XCTAssertEqual(view.state.movies, [item1])
            case 1: XCTAssertEqual(view.state.movies, [item1, item2])
            case 2: XCTAssertEqual(view.state.movies, [item1, item2, item3])
            default: break
            }
        }
    }
    
    typealias SUT = MovieListComposer<Text>
    func makeSUT(loader: @escaping MoviesLoader) -> SUT {
        MovieListComposer<Text>(loader: loader) { _ in Text("any thumbnail") }
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

fileprivate func anyMovie(id: Int = 0) -> Movie {
    Movie(id: id.description, title: "some title", posterURL: "someposterurl", releaseYear: 2000)
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
