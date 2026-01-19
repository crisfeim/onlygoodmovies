import Movies
import SwiftUI
import XCTest

@MainActor
class MoviesLoadTestCase: XCTestCase {
    func test_initDoesntMutatesState() {
        let (_, state) = makeSUT()
        XCTAssertEqual(state(), MoviesState())
    }
    
    func test_loadDeliversErrorOnLoaderFailure() async {
        let (sut, state) = makeSUT() { AsyncThrowingStream { $0.finish(throwing: anyError()) } }
        await sut.firstLoad()
        XCTAssertFalse(state().showLoading)
        XCTAssertTrue(state().showError)
        XCTAssertFalse(state().showEmpty)
        XCTAssertEqual(state().movies, [], "Expected placeholder movies to be cleaned")
    }
    
    func test_loadSetsMoviesToPlaceholdersWhileLoading() async {
        let spy = BindingSpy()
        let anyConfig = makeBinding(MoviesConfig())
        let sut = MoviesPresenter(spy.binding, anyConfig, loader: anyLoader())
        await sut.firstLoad()
        XCTAssertEqual(spy.capturedStates.first?.movies, .placeholders)
    }
    
    func test_loadDeliversMoviesOnLoaderSuccess() async {
        let (sut, state) = makeSUT() { AsyncThrowingStream { $0.yield(mockMovie()) ; $0.finish() } }
        await sut.firstLoad()
        XCTAssertEqual(state().movies, [mockMovie()])
        XCTAssertFalse(state().showLoading)
        XCTAssertFalse(state().showEmpty)
        XCTAssertFalse(state().showError)
    }
    
    func test_loadShowsEmptyOnLoaderSuccessWithEmptyData() async {
        let (sut, state) = makeSUT()
        await sut.firstLoad()
        XCTAssertEqual(state().movies, [])
        XCTAssertFalse(state().showLoading)
        XCTAssertTrue(state().showEmpty)
        XCTAssertFalse(state().showError)
    }
    
    func makeSUT(_ state: MoviesState = MoviesState(), loader: @escaping MoviesLoader = anyLoader()) -> (MoviesPresenter, () -> MoviesState) {
        let state = makeBinding(state)
        let config = makeBinding(MoviesConfig())
        return (MoviesPresenter(state, config, loader: loader), { state.wrappedValue })
    }
}
