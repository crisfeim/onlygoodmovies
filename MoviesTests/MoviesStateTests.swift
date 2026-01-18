// © 2026  Cristian Felipe Patiño Rojas. Created on 18/1/26.

import XCTest
import Movies

class MoviesStateTests: XCTestCase {
    func test_assertInitialState() {
        let state = MoviesState()
        XCTAssertEqual(state.movies, [])
        XCTAssertTrue(state.showLoading)
        XCTAssertFalse(state.showError)
        XCTAssertFalse(state.showEmpty)
    }
}
