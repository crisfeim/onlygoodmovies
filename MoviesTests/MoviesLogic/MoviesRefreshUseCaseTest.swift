// © 2026  Cristian Felipe Patiño Rojas. Created on 18/1/26.

import SwiftUI
import XCTest
import Movies

@MainActor
class MoviesRefreshUseCaseTest: XCTestCase {
    
    func test_initDoesntMutatesState() {
        let (_, state) = makeSUT()
        XCTAssertEqual(state(), MoviesState())
    }
    
    func test_refreshShowsErrorOnLoaderFailure() async {
        let (sut, state) = makeSUT(.previouslyLoaded()) { throw anyError() }
        await sut.refresh()
        XCTAssertFalse(state().showLoading)
        XCTAssertTrue(state().showError)
    }
    
    func test_refreshDeliversMoviesOnLoaderSuccess() async {
        let (sut, state) = makeSUT(.previouslyLoaded()) { [mockMovie()] }
        await sut.refresh()
        XCTAssertEqual(state().movies, [mockMovie()])
        XCTAssertEqual(state().showLoading, false)
    }
    
    func test_refreshHidesError() async {
        let spy = BindingSpy(initState: .loadedWithError())
        let sut = MoviesLogic(spy.binding, loader: anyLoader())
        await sut.refresh()
        XCTAssertFalse(spy.capturedStates[0].showError)
    }
    
    func test_refreshIsNotTriggeredWhileLoading() async {
        let spy = BindingSpy()
        let sut = MoviesLogic(spy.binding, loader: anyLoader())
        await sut.refresh()
        XCTAssertEqual(spy.capturedStates.count, 0)
    }
    
    func makeSUT(_ state: MoviesState = MoviesState(), loader: @escaping MoviesLoader = anyLoader()) -> (MoviesLogic, () -> MoviesState) {
        let binding = makeBinding(state)
        return (MoviesLogic(binding, loader: loader), { binding.wrappedValue })
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
    
    static func previouslyLoaded(hasError: Bool = false) -> Self {
        .init(movies: [], showLoading: false, showError: hasError, showEmpty: true)
    }
}
