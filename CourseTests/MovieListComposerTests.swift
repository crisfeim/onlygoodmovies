// © 2026  Cristian Felipe Patiño Rojas. Created on 3/1/26.

@testable import Course
import XCTest
import SwiftUI
import Movies

/*
 See "Testable SwiftUI Views with async/await" by Lazar Ostatevic.
 https://medium.com/@redhotbits/testable-swiftui-views-dd268d15a10e
*/

@MainActor
final class MovieListComposerTests: XCTestCase {
    func test_moviesAreStreamedAfterRendered() async throws {
        let expected = [anyMovie(id: 1), anyMovie(id: 2), anyMovie(id: 3)]
        renderSUT(loader: expected.stream)
        
        let placeholder = try await SUT.wait(1) { $0.state.movies.contains(.placeholder) }
        XCTAssertNotNil(placeholder)
        
        let oneitem = try await SUT.wait(1) { $0.state.movies.count == 2 }
        XCTAssertNotNil(oneitem)
        
        let final = try await SUT.wait(1) { $0.state.movies == expected }
        XCTAssertNotNil(final)
    }
    
    typealias SUT = MovieListComposer<Text>
    @discardableResult
    func renderSUT(loader: @escaping MoviesLoader)  -> SUT {
        let sut = MovieListComposer<Text>(loader: loader) { _ in Text("any thumbnail") }
        TestApp.shared.setView(sut)
        return sut
    }
}

import Combine
extension MovieListComposerTests.SUT {
    @MainActor
    static func wait(
        _ timeout: TimeInterval,
        for predicate: @MainActor @escaping (Self) -> Bool
    ) async throws -> Self? {
        return try await withThrowingTaskGroup(of: Self?.self) { group in
            group.addTask { @Sendable in
                let notifications = NotificationCenter.default
                    .publisher(for: bodyEvaluationNotification)
                    .values
                
                for await notification in notifications {
                    if let view = notification.object as? Self, await predicate(view) {
                        return view
                    }
                }
                return nil
            }
            
            group.addTask {
                try await Task.sleep(for: .seconds(timeout))
                return nil
            }
            
            let result = try await group.next()
            group.cancelAll()
            return result.flatMap { $0 }
        }
    }
}

extension MovieListComposerTests.SUT: @retroactive StateRegistrator {
    public var registeredState: Any { state }
}

fileprivate extension Array where Element: Sendable {
    var stream: @Sendable () -> AsyncThrowingStream<Element, Error> {
        {
            AsyncThrowingStream { continuation in
                Task {
                    for item in self {
                        try await Task.sleep(for: .milliseconds(50))
                        continuation.yield(item)
                    }
                    continuation.finish()
                }
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

