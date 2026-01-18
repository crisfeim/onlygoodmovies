import SwiftUI
import XCTest
import Movies

@MainActor
class MoviesLoadTestCase: XCTestCase {
    func test_initDoesntMutatesState() {
        let (_, state) = makeSUT()
        XCTAssertEqual(state(), MoviesState())
    }
    
    func test_loadDeliversErrorOnLoaderFailure() async {
        let (sut, state) = makeSUT() { throw anyError() }
        await sut.load()
        XCTAssertFalse(state().showLoading)
        XCTAssertTrue(state().showError)
        XCTAssertFalse(state().showEmpty)
        XCTAssertEqual(state().movies, [], "Expected placeholder movies to be cleaned")
    }
    
    func test_loadSetsMoviesToPlaceholdersWhileLoading() async {
        let spy = BindingSpy()
        let anyConfig = makeBinding(MoviesConfig())
        let sut = MoviesLogic(spy.binding, anyConfig, loader: anyLoader())
        await sut.load()
        XCTAssertEqual(spy.capturedStates.first?.movies, .placeholders)
    }
    
    func test_loadDeliversMoviesOnLoaderSuccess() async {
        let (sut, state) = makeSUT() { [mockMovie()] }
        await sut.load()
        XCTAssertEqual(state().movies, [mockMovie()])
        XCTAssertFalse(state().showLoading)
        XCTAssertFalse(state().showEmpty)
        XCTAssertFalse(state().showError)
    }
    
    func test_loadShowsEmptyOnLoaderSuccessWithEmptyData() async {
        let (sut, state) = makeSUT() { [] }
        await sut.load()
        XCTAssertEqual(state().movies, [])
        XCTAssertFalse(state().showLoading)
        XCTAssertTrue(state().showEmpty)
        XCTAssertFalse(state().showError)
    }
    
    func makeSUT(_ state: MoviesState = MoviesState(), loader: @escaping MoviesLoader = anyLoader()) -> (MoviesLogic, () -> MoviesState) {
        let state = makeBinding(state)
        let config = makeBinding(MoviesConfig())
        return (MoviesLogic(state, config, loader: loader), { state.wrappedValue })
    }
}
