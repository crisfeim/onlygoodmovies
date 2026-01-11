import SwiftUI
import XCTest
@preconcurrency import Core


class MoviesTests: XCTestCase {
    
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
        let (sut, state) = makeSUT() { throw anyError() }
        await sut.load()
        XCTAssertFalse(state.wrappedValue.isLoading)
        XCTAssertTrue(state.wrappedValue.hasError)
    }
    
    func test_loadDeliversMoviesOnLoaderSuccess() async {
        let movie = Movie(id: "id", title: "title", poster_url: "potter_url", release_year: 2020)
        let (sut, state) = makeSUT() { [movie] }
        await sut.load()
        XCTAssertEqual(state.wrappedValue.movies, [movie])
        XCTAssertEqual(state.wrappedValue.isLoading, false)
    }
    
    func test_refreshShowsErrorOnLoaderFailure() async {
        let (sut, state) = makeSUT(.previouslyLoaded()) { throw anyError() }
        await sut.refresh()
        XCTAssertFalse(state.wrappedValue.isLoading)
        XCTAssertTrue(state.wrappedValue.hasError)
    }
    
    func test_refreshDeliversMoviesOnLoaderSuccess() async {
        let movie = Movie(id: "id", title: "title", poster_url: "potter_url", release_year: 2020)
        let (sut, state) = makeSUT(.previouslyLoaded()) { [movie] }
        await sut.refresh()
        XCTAssertEqual(state.wrappedValue.movies, [movie])
        XCTAssertEqual(state.wrappedValue.isLoading, false)
    }
    
    func test_refreshHidesError() async {
        var prev = MoviesState.previouslyLoaded(hasError: true)
        var states = [MoviesState]()
        let binding = Binding(get: { prev }, set: { prev = $0  ; states.append($0) })
        let sut = MoviesLogic(state: binding, loader: anyLoader())
        await sut.refresh()
        XCTAssertFalse(states[0].hasError)
        print(states)
    }
    
    func test_ensureUserCantRefreshWhileLoading() async {
        var prev = MoviesState()
        var states = [MoviesState]()
        let binding = Binding(get: { prev }, set: { prev = $0  ; states.append($0) })
        let sut = MoviesLogic(state: binding, loader: anyLoader())
        await sut.refresh()
        XCTAssertEqual(states.count, 0)
        print(states)
    }
    
    func makeSUT(_ state: MoviesState = MoviesState(), loader: @escaping MoviesLoader = anyLoader()) -> (MoviesLogic, Binding<MoviesState>) {
        let binding = makeBinding(state)
        return (MoviesLogic(state: binding, loader: loader), binding)
    }
    

}


fileprivate func anyLoader() -> MoviesLoader {{[]}}

fileprivate func makeBinding<T>(_ value: T) -> Binding<T> {
   var value = value
   return Binding(get: { value }, set: { value = $0 })
}


func anyError() -> Error {
    NSError(domain: "any-error", code: 0)
}

fileprivate extension MoviesState {
    static func previouslyLoaded(hasError: Bool = false) -> Self {
        .init(movies: [], hasError: hasError)
    }
}
