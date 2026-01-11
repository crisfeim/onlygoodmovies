import SwiftUI
import XCTest
@preconcurrency import Core


class MoviesTests: XCTestCase {
    
    func test_assertInitialState() {
        let state = MoviesState()
        XCTAssertEqual(state.movies, [])
        XCTAssertTrue(state.isLoading)
        XCTAssertFalse(state.hasError)
    }
    
    func test_initDoesntMutatesState() {
        let (_, state) = makeSUT()
        XCTAssertEqual(state().movies, [])
        XCTAssertTrue(state().isLoading)
        XCTAssertFalse(state().hasError)
    }
    
    func test_loadDeliversErrorOnLoaderFailure() async {
        let (sut, state) = makeSUT() { throw anyError() }
        await sut.load()
        XCTAssertFalse(state().isLoading)
        XCTAssertTrue(state().hasError)
    }
    
    func test_loadDeliversMoviesOnLoaderSuccess() async {
        let (sut, state) = makeSUT() { [mockMovie()] }
        await sut.load()
        XCTAssertEqual(state().movies, [mockMovie()])
        XCTAssertEqual(state().isLoading, false)
    }
    
    func test_refreshShowsErrorOnLoaderFailure() async {
        let (sut, state) = makeSUT(.previouslyLoaded()) { throw anyError() }
        await sut.refresh()
        XCTAssertFalse(state().isLoading)
        XCTAssertTrue(state().hasError)
    }
    
    func test_refreshDeliversMoviesOnLoaderSuccess() async {
        let (sut, state) = makeSUT(.previouslyLoaded()) { [mockMovie()] }
        await sut.refresh()
        XCTAssertEqual(state().movies, [mockMovie()])
        XCTAssertEqual(state().isLoading, false)
    }
    
    func test_refreshHidesError() async {
        var capturedStates = [MoviesState]()
        let sut = MoviesLogic(state: .init(get: { .loadedWithError() }, set: { capturedStates.append($0) }), loader: anyLoader())
        await sut.refresh()
        XCTAssertFalse(capturedStates[0].hasError)
    }
    
    func test_refreshIsNotTriggeredWhileLoading() async {
        var capturedStates = [MoviesState]()
        let sut = MoviesLogic(state: .init(get: { .init() }, set: { capturedStates.append($0) }), loader: anyLoader())
        await sut.refresh()
        XCTAssertEqual(capturedStates.count, 0)
    }
    
    func makeSUT(_ state: MoviesState = MoviesState(), loader: @escaping MoviesLoader = anyLoader()) -> (MoviesLogic, () -> MoviesState) {
        let binding = makeBinding(state)
        return (MoviesLogic(state: binding, loader: loader), { binding.wrappedValue })
    }
}


fileprivate func anyLoader() -> MoviesLoader {{[]}}

fileprivate func makeBinding<T>(_ value: T) -> Binding<T> {
   var value = value
   return Binding(get: { value }, set: { value = $0 })
}

fileprivate func mockMovie() -> Movie {
    Movie(id: "id", title: "title", poster_url: "potter_url", release_year: 2020)
}

fileprivate func anyError() -> Error {
    NSError(domain: "any-error", code: 0)
}

fileprivate extension MoviesState {
    static func loadedWithError() -> Self {
        previouslyLoaded(hasError: true)
    }
    
    static func previouslyLoaded(hasError: Bool = false) -> Self {
        .init(movies: [], hasError: hasError)
    }
}
