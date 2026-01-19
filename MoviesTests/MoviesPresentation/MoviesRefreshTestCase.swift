// © 2026  Cristian Felipe Patiño Rojas. Created on 18/1/26.

import Movies
import SwiftUI
import XCTest

@MainActor
class MoviesRefreshTestCase: XCTestCase {
    
    func test_initDoesntMutatesState() {
        let (_, state) = makeSUT()
        XCTAssertEqual(state(), MoviesState())
    }
    
    func test_refreshShowsErrorOnLoaderFailure() async {
        let (sut, state) = makeSUT(.previouslyLoaded()) { AsyncThrowingStream { $0.finish(throwing: anyError()) } }
        await sut.refresh()
        XCTAssertFalse(state().showLoading)
        XCTAssertTrue(state().showError)
    }
    
    func test_refreshDeliversMoviesOnLoaderSuccess() async {
        let (sut, state) = makeSUT(.previouslyLoaded()) { AsyncThrowingStream { $0.yield(mockMovie()) ; $0.finish() } }
        await sut.refresh()
        XCTAssertEqual(state().movies, [mockMovie()])
        XCTAssertEqual(state().showLoading, false)
    }
    
    func test_refreshDoesntDestroysMoviesOnFailure() async {
        let (sut, state) = makeSUT(.previouslyLoaded(movies: [mockMovie(), mockMovie()])) { AsyncThrowingStream { $0.finish(throwing: anyError()) } }
        await sut.refresh()
        XCTAssertEqual(state().movies, [mockMovie(), mockMovie()])
        XCTAssertEqual(state().showLoading, false)
    }
    
    func test_refreshHidesError() async {
        let spy = BindingSpy(initState: .loadedWithError())
        let anyConfig = makeBinding(MoviesConfig())
        let sut = MoviesPresenter(spy.binding, anyConfig, loader: anyLoader())
        await sut.refresh()
        XCTAssertFalse(spy.capturedStates[0].showError)
    }
    
    func test_refreshIsNotTriggeredWhileLoading() async {
        let spy = BindingSpy()
        let anyConfig = makeBinding(MoviesConfig())
        let sut = MoviesPresenter(spy.binding, anyConfig, loader: anyLoader())
        await sut.refresh()
        XCTAssertEqual(spy.capturedStates.count, 0)
    }
    
    func makeSUT(_ state: MoviesState = MoviesState(), loader: @escaping MoviesLoader = anyLoader()) -> (MoviesPresenter, () -> MoviesState) {
        let state = makeBinding(state)
        let config = makeBinding(MoviesConfig())
        return (MoviesPresenter(state, config, loader: loader), { state.wrappedValue })
    }
    
    
    fileprivate class BindingSpy {
        var capturedStates: [MoviesState] = []
        private let initState: MoviesState
        
        init(initState: MoviesState = .init()) {
            self.initState = initState
        }
        
        @MainActor
        var binding: Binding<MoviesState> {
            .init(get: { self.initState }, set: { self.capturedStates.append($0) })
        }
    }
}

fileprivate extension MoviesState {
    static func loadedWithError() -> Self {
        previouslyLoaded(hasError: true)
    }
    
    static func previouslyLoaded(movies: [Movie] = [], hasError: Bool = false) -> Self {
        .init(movies: movies, showLoading: false, showError: hasError, showEmpty: true)
    }
}
