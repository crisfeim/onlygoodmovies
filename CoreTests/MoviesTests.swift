

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
        let (_, state) = makeSUT()
        XCTAssertNil(state.wrappedValue.movies)
        XCTAssertTrue(state.wrappedValue.isLoading)
        XCTAssertFalse(state.wrappedValue.hasError)
    }
    
    func test_loadDeliversErrorOnLoaderFailure() async {
        let (sut, state) = makeSUT() { throw NSError(domain: "any-error", code: 0) }
        await sut.initLoad()
        XCTAssertFalse(state.wrappedValue.isLoading)
        XCTAssertTrue(state.wrappedValue.hasError)
    }
    
    func test_loadDeliversMoviesOnLoaderSuccess() async {
        let movie = Movie(id: UUID(), name: "anymovie")
        let (sut, state) = makeSUT() { [movie] }
        await sut.initLoad()
        XCTAssertEqual(state.wrappedValue.movies, [movie])
        XCTAssertEqual(state.wrappedValue.isLoading, false)
    }
    
    func test_refreshShowsErrorOnLoaderFailure() async {
        let (sut, state) = makeSUT(.previouslyLoaded()) { throw NSError(domain: "any-error", code: 0) }
        await sut.refresh()
        XCTAssertFalse(state.wrappedValue.isLoading)
        XCTAssertTrue(state.wrappedValue.hasError)
    }
    
    func test_refreshDeliversMoviesOnLoaderSuccess() async {
        let movie = Movie(id: UUID(), name: "anymovie")
        let (sut, state) = makeSUT(.previouslyLoaded()) { [movie] }
        await sut.refresh()
        XCTAssertEqual(state.wrappedValue.movies, [movie])
        XCTAssertEqual(state.wrappedValue.isLoading, false)
    }
    
    func test_refreshHidesError() async {
        var prev = MoviesState.previouslyLoaded(hasError: true)
        var states = [MoviesState]()
        let binding = Binding(get: { prev }, set: { prev = $0  ; states.append($0) })
        let sut = MoviesLogic(state: binding, loader: Self.anyLoader())
        await sut.refresh()
        XCTAssertEqual(states[0].hasError, false)
        print(states)
    }
    
    func makeSUT(_ state: MoviesState = MoviesState(), loader: @escaping MoviesLoader = anyLoader()) -> (MoviesLogic, Binding<MoviesState>) {
        let binding = Self.makeBinding(state)
        return (MoviesLogic(state: binding, loader: loader), binding)
    }
    
    typealias MoviesLoader = () async throws -> [Movie]
    static func anyLoader() -> MoviesLoader {{[ ]}}
    
    static func makeBinding<T>(_ value: T) -> Binding<T> {
       var value = value
       return Binding(get: { value }, set: { value = $0 })
    }

}


fileprivate extension MoviesTests.MoviesState {
    static func previouslyLoaded(hasError: Bool = false) -> Self {
        .init(movies: [], hasError: hasError, isLoading: false)
    }
}
