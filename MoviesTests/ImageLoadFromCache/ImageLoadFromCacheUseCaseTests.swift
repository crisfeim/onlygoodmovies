import XCTest
import SwiftUI
@testable import Movies

@MainActor
class ImageLoadFromCacheUseCaseTests: XCTestCase, ImageLoadFromCacheUseCase {
    
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
    
    func test_initDoesntMessagesTheStoreIfImageIsAlreadySet() {
        nonisolated(unsafe) var count = 0
        let (_, _)  = makeSUT(.success(Image(""))) { _ in
            count += 1
            return Image("")
        }
        XCTAssertEqual(count, 1)
    }
    
    func makeSUT(url: URL? = anyURL(), _ phase: AsyncImagePhase = .empty, store: @escaping ImagesStore = { _ in nil }) -> (sut: ResourceImageLogic, state: () -> AsyncImagePhase) {
        let sut = ResourceImageLogic(phase: phase, url: url, store: store, loader: { _ in nil })
        return (sut: sut, state: { sut.phase })
    }
}

