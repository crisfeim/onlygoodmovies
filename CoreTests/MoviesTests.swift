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
        let spy = BindingSpy(initState: .loadedWithError())
        let sut = MoviesLogic(state: spy.binding, loader: anyLoader())
        await sut.refresh()
        XCTAssertFalse(spy.capturedStates[0].hasError)
    }
    
    func test_refreshIsNotTriggeredWhileLoading() async {
        let spy = BindingSpy()
        let sut = MoviesLogic(state: spy.binding, loader: anyLoader())
        await sut.refresh()
        XCTAssertEqual(spy.capturedStates.count, 0)
    }
    
    func makeSUT(_ state: MoviesState = MoviesState(), loader: @escaping MoviesLoader = anyLoader()) -> (MoviesLogic, () -> MoviesState) {
        let binding = makeBinding(state)
        return (MoviesLogic(state: binding, loader: loader), { binding.wrappedValue })
    }
    
    fileprivate class BindingSpy {
        var capturedStates: [MoviesState] = []
        private let initState: MoviesState
        
        init(initState: MoviesState = .init()) {
            self.initState = initState
        }
        
        var binding: Binding<MoviesState> {
            .init(get: { self.initState }, set: { self.capturedStates.append($0) })
        }
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
