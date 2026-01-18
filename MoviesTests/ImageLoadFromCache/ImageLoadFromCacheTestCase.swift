import XCTest
import SwiftUI
@testable import Movies

@MainActor
class ImageLoadFromCacheTestCase: XCTestCase, ImageLoadTestCase {
    
    func test_initDoesntDeliverResultOnEmptyStore() {
        let (_, state) = makeSUT()
        XCTAssertTrue(isEmpty(state()))
    }
    
    func test_initDeliversResultOnNonEmptyStore() {
        let (_, state) = makeSUT() { _ in Image("") }
        XCTAssertFalse(isEmpty(state()))
    }
    
    func test_initDoesntDeliverImageOnEmptyStore() {
        let (_, state) = makeSUT()
        XCTAssertTrue(isEmpty(state()))
    }
    
    func test_initDoesntDeliverImageIfURLDoesntMatchWhenNonEmptyStore() {
        let (_, state) = makeSUT() { url in
            if url != URL(string: "https://stored.com") { return nil }
            return Image("")
        }
        XCTAssertTrue(isEmpty(state()))
    }
    
    func test_loadDeliversImageIfURLMatchesWithStoredImage() {
        let (_, state) = makeSUT() { url in url == anyURL()! ? Image("") : nil }
        XCTAssertEqual(state().image, Image(""))
    }
    
    func makeSUT(url: URL? = anyURL(), _ phase: AsyncImagePhase = .empty, store: @escaping ImagesStore = { _ in nil }) -> (sut: ResourceImageCoordinator, state: () -> AsyncImagePhase) {
        let sut = ResourceImageCoordinator(phase: phase, url: url, store: store, loader: { _ in nil })
        return (sut: sut, state: { sut.phase })
    }
}

