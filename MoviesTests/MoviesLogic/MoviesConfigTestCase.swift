import SwiftUI
import XCTest
import Movies


@MainActor
class MoviesConfigTestCase: XCTestCase {
    
    func test_loadResetsConfigOnLoaderFailure() async {
        let (sut, config) = makeSUT() { throw anyError() }
        await sut.load()
        XCTAssertEqual(config(), .init())
    }
    
    func makeSUT(_ state: MoviesConfig = MoviesConfig(), loader: @escaping MoviesLoader = anyLoader()) -> (MoviesLogic, () -> MoviesConfig) {
        let binding = makeBinding(state)
        let anyState = makeBinding(MoviesState())
        return (MoviesLogic(anyState, loader: loader), { binding.wrappedValue })
    }
}
