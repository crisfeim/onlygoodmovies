

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
            state.hasError = false
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
        let state = makeBinding(MoviesState())
        let _ = makeSUT(state)
        XCTAssertNil(state.wrappedValue.movies)
        XCTAssertTrue(state.wrappedValue.isLoading)
        XCTAssertFalse(state.wrappedValue.hasError)
    }
    
    func test_loadDeliversErrorOnLoaderFailure() async {
        let state = makeBinding(MoviesState())
        let sut = makeSUT(state) { throw NSError(domain: "any-error", code: 0) }
        await sut.initLoad()
        XCTAssertFalse(state.wrappedValue.isLoading)
        XCTAssertTrue(state.wrappedValue.hasError)
    }
    
    func test_loadDeliversMoviesOnLoaderSuccess() async {
        let state = makeBinding(MoviesState())
        let movie = Movie(id: UUID(), name: "anymovie")
        let sut = makeSUT(state) { [movie] }
        await sut.initLoad()
        XCTAssertEqual(state.wrappedValue.movies, [movie])
        XCTAssertEqual(state.wrappedValue.isLoading, false)
    }
    
    func test_refreshShowsErrorOnLoaderFailure() async {
        let state = makeBinding(previouslyLoadedState())
        let sut = makeSUT(state) { throw NSError(domain: "any-error", code: 0) }
        await sut.refresh()
        XCTAssertFalse(state.wrappedValue.isLoading)
        XCTAssertTrue(state.wrappedValue.hasError)
    }
    
    func test_refreshDeliversMoviesOnLoaderSuccess() async {
        let state = makeBinding(previouslyLoadedState())
        let movie = Movie(id: UUID(), name: "anymovie")
        let sut = makeSUT(state) { [movie] }
        await sut.refresh()
        XCTAssertEqual(state.wrappedValue.movies, [movie])
        XCTAssertEqual(state.wrappedValue.isLoading, false)
    }
    
    func test_refreshHidesError() async {
        var state = previouslyLoadedState(hasError: true)
        var states = [MoviesState]()
        let binding = Binding(get: { state }, set: { state = $0  ; states.append($0) })

        let sut = makeSUT(binding)
        await sut.refresh()
        XCTAssertEqual(states[0].hasError, false)
        print(states)
    }
    
    func previouslyLoadedState(hasError: Bool = false) -> MoviesState {
        .init(movies: [], hasError: hasError, isLoading: false)
    }
    

    
    func makeSUT(_ binding: Binding<MoviesState>, loader: @escaping MoviesLoader = anyLoader()) -> MoviesLogic {
        MoviesLogic(state: binding, loader: loader)
    }
    
    typealias MoviesLoader = () async throws -> [Movie]
    static func anyLoader() -> MoviesLoader {
        { [ ]}
    }
    
    func makeBinding<T>(_ value: T) -> Binding<T> {
       var value = value
       return Binding(get: { value }, set: { value = $0 })
    }

}

