

import SwiftUI
import XCTest



class MoviesTests: XCTestCase {
     struct MoviesState {
         var movies: [Movie]?
         var hasError = false
         var isLoading = true
    }
    
    struct MoviesLogic {
        @Binding var state: MoviesState
        let loader: () async throws -> [Movie]
        func load() async {
            do {
                state.movies = try await loader()
            } catch {
                state.isLoading = false
                state.hasError = true
            }
        }
    }
    
    func test_assertInitialState() {
        let state = MoviesState()
        XCTAssertNil(state.movies)
        XCTAssertTrue(state.isLoading)
        XCTAssertFalse(state.hasError)
    }
    
    func test_initDoesntMutatesState() {
        var state = MoviesState()
        let binding = Binding(get: { state }, set: { state = $0 })
        let _ = makeSUT(binding)
        XCTAssertNil(state.movies)
        XCTAssertTrue(state.isLoading)
        XCTAssertFalse(state.hasError)
    }
    
    func test_deliversErrorOnLoaderFailure() async {
        var state = MoviesState()
        let binding = Binding(get: { state }, set: { state = $0 })
        let sut = makeSUT(binding) { throw NSError(domain: "any-error", code: 0) }
        await sut.load()
        XCTAssertFalse(state.isLoading)
        XCTAssertTrue(state.hasError)
    }
    
    func test_deliversMoviesOnLoaderSuccess() async {
        var state = MoviesState()
        let binding = Binding(get: { state }, set: { state = $0 })
        let movie = Movie(id: UUID(), name: "anymovie")
        let sut = makeSUT(binding) { [movie] }
        await sut.load()
        XCTAssertEqual(state.movies, [movie])
    }
    
    func makeSUT(_ binding: Binding<MoviesState>, loader: @escaping MoviesLoader = anyLoader()) -> MoviesLogic {
        MoviesLogic(state: binding, loader: loader)
    }
    
    typealias MoviesLoader = () async throws -> [Movie]
    static func anyLoader() -> MoviesLoader {
        { [ ]}
    }

}

