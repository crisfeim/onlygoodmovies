import XCTest
import SwiftUI
import Movies

@MainActor
class ImageLoadFromCacheUseCaseTests: XCTestCase, ImageLoadFromCacheUseCase {
    
    func test_initDoesntDeliverResult() {
        let (_, state) = makeSUT()
        XCTAssertTrue(isEmpty(state()))
    }
    
    func test_loadDoesntDeliverImageOnEmptyStore() {
        let (sut, state) =  makeSUT()
        sut.load()
        XCTAssertTrue(isEmpty(state()))
    }
    
    func test_loadDoesntDeliverImageIfURLDoesntMatchWhenNonEmptyStore() {
        let (sut, state) = makeSUT() { url in
            if url != URL(string: "https://stored.com") { return nil }
            return Image("")
        }
        sut.load()
        XCTAssertTrue(isEmpty(state()))
    }
    
    func test_loadDeliversImageIfURLMatchesWithStoredImage() {
        let (sut, state) = makeSUT() { url in url == anyURL()! ? Image("") : nil }
        sut.load()
        XCTAssertEqual(state().image, Image(""))
    }
    
    func test_loadDoesntMessagesTheStoreIfImageIsAlreadySet() {
        var storeCalled = false
        let (sut, _)  = makeSUT(.success(Image(""))) { _ in
            storeCalled = true
            return Image("")
        }
        sut.load()
        XCTAssertFalse(storeCalled)
    }
    
    func makeSUT(url: URL? = anyURL(), _ phase: AsyncImagePhase = .empty, store: @escaping ImagesStore = { _ in nil }) -> (sut: AsyncImageLogic, state: () -> AsyncImagePhase) {
        let binding = makeBinding(phase)
        return (sut: AsyncImageLogic(url: url, phase: binding, store: store, loader: { _ in nil }), state: { binding.wrappedValue })
    }
}

