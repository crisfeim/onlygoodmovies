

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
        func initLoad() async {
            defer { state.isLoading = false }
            await load()
        }
        
        func refresh() async {
            await load()
        }
        
        private func load() async {
            do {
                state.movies = try await loader()
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
    
    func test_loadDeliversErrorOnLoaderFailure() async {
        var state = MoviesState()
        let binding = Binding(get: { state }, set: { state = $0 })
        let sut = makeSUT(binding) { throw NSError(domain: "any-error", code: 0) }
        await sut.initLoad()
        XCTAssertFalse(state.isLoading)
        XCTAssertTrue(state.hasError)
    }
    
    func test_loadDeliversMoviesOnLoaderSuccess() async {
        var state = MoviesState()
        let binding = Binding(get: { state }, set: { state = $0 })
        let movie = Movie(id: UUID(), name: "anymovie")
        let sut = makeSUT(binding) { [movie] }
        await sut.initLoad()
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
    
    func test_refreshDeliversMoviesOnLoaderSuccess() async {
        var state = previouslyLoadedState()
        let binding = Binding(get: { state }, set: { state = $0 })
        let movie = Movie(id: UUID(), name: "anymovie")
        let sut = makeSUT(binding) { [movie] }
        await sut.refresh()
        XCTAssertEqual(state.movies, [movie])
        XCTAssertEqual(state.isLoading, false)
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

