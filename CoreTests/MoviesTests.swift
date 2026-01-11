

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
            defer { state.isLoading = false }
            do {
                state.movies = try await loader()
            } catch {
                state.hasError = true
            }
        }
        
        func refresh() async {
            do {
                _ =  try await loader()
            } catch {
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
        XCTAssertEqual(state.isLoading, false)
    }
    
    func test_refreshShowsErrorOnLoaderFailure() async {
        var previouslyLoadedState = previouslyLoadedState()
        let binding = Binding(get: { previouslyLoadedState }, set: { previouslyLoadedState = $0 })
        let sut = makeSUT(binding) { throw NSError(domain: "any-error", code: 0) }
        await sut.refresh()
        XCTAssertFalse(previouslyLoadedState.isLoading)
        XCTAssertTrue(previouslyLoadedState.hasError)
    }
    
    func previouslyLoadedState() -> MoviesState {
        .init(movies: [], hasError: false, isLoading: false)
    }

    
    func makeSUT(_ binding: Binding<MoviesState>, loader: @escaping MoviesLoader = anyLoader()) -> MoviesLogic {
        MoviesLogic(state: binding, loader: loader)
    }
    
    typealias MoviesLoader = () async throws -> [Movie]
    static func anyLoader() -> MoviesLoader {
        { [ ]}
    }

}

