// © 2026  Cristian Felipe Patiño Rojas. Created on 8/1/26.

import XCTest

class StoreTests: XCTestCase {
    struct Store {
        private(set) var movies = [String]()
        private(set) var showLoading = true
        private(set) var showEmpty = false
        private(set) var showError = false
        
        mutating func displayError() {
            showLoading = false
            showError = true
        }
        
        mutating func dismissError() {
            showError = false
        }
        
        mutating func displayMovies(_ movies: [String]) {
            self.movies = movies
            showLoading = false
            showEmpty = movies.isEmpty
            showError = false
        }
        
        mutating func refresh() {
            showError = false
        }
    }
    
    func test() {
        let sut = Store()
        XCTAssertTrue(sut.showLoading)
        XCTAssertFalse(sut.showEmpty)
        XCTAssertFalse(sut.showError)
    }
    
    func test_displayErrorOnInitialLoad() {
        var sut = Store()
        sut.displayError()
        XCTAssertEqual(sut.movies, [])
        XCTAssertFalse(sut.showLoading)
        XCTAssertFalse(sut.showEmpty)
        XCTAssertTrue(sut.showError)
    }
    
    func test_displayMovies() {
        var sut = Store()
        sut.displayMovies([""])
        XCTAssertEqual(sut.movies, [""])
        XCTAssertFalse(sut.showLoading)
        XCTAssertFalse(sut.showEmpty)
        XCTAssertFalse(sut.showError)
    }
    
    func test_displayEmptyMovies() {
        var sut = Store()
        sut.displayMovies([])
        XCTAssertEqual(sut.movies, [])
        XCTAssertFalse(sut.showLoading)
        XCTAssertTrue(sut.showEmpty)
        XCTAssertFalse(sut.showError)
    }
    
    func testDisplayErrorOnRefresh_withExistentMovies() {
        var sut = Store()
        sut.displayMovies([""])
        sut.displayError()
        XCTAssertEqual(sut.movies, [""])
        XCTAssertFalse(sut.showLoading)
        XCTAssertFalse(sut.showEmpty)
        XCTAssertTrue(sut.showError)
    }
    
    func testDisplayErrorOnRefresh_withEmptyData() {
        var sut = Store()
        sut.displayMovies([])
        sut.displayError()
        XCTAssertEqual(sut.movies, [])
        XCTAssertFalse(sut.showLoading)
        XCTAssertTrue(sut.showEmpty)
        XCTAssertTrue(sut.showError)
    }
    
    func testRefreshAfterErrorHidesError() {
        var sut = Store()
        sut.displayError()
        sut.refresh()
        XCTAssertEqual(sut.movies, [])
        XCTAssertFalse(sut.showLoading)
        XCTAssertFalse(sut.showEmpty)
        XCTAssertFalse(sut.showError)
    }
    
    func test_dismissErrorAfterLoadingDismissesError() {
        var sut = Store()
        sut.displayMovies([])
        sut.displayError()
        sut.dismissError()
        XCTAssertFalse(sut.showError)
    }
}
