import XCTest
import SwiftUI
import Movies

@MainActor
class ImageLoadFromCacheUseCaseTests: XCTestCase {
    
    func test_initDoesntDeliverResult() {
        let (_, state) = makeSUT()
        XCTAssertNil(state())
    }
    
    func test_loadDoesntDeliverImageOnEmptyStore() {
        let (sut, state) =  makeSUT()
        sut.load()
        XCTAssertNil(state())
    }
    
    func test_loadDoesntDeliverImageIfURLDoesntMatchWhenNonEmptyStore() {
        let (sut, state) = makeSUT() { url in
            if url != URL(string: "https://stored.com") { return nil }
            return Image("")
        }
        sut.load()
        XCTAssertNil(state())
    }
    
    func test_loadDeliversImageIfURLMatchesWithStoredImage() {
        let (sut, state) = makeSUT() { url in url == anyURL()! ? Image("") : nil }
        sut.load()
        XCTAssertEqual(try? state()?.get(), Image(""))
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
    
    func makeSUT(url: URL? = anyURL(), _ result: AsyncImageLogic.Result? = nil, store: @escaping ImagesStore = { _ in nil }) -> (sut: AsyncImageLogic, state: () -> AsyncImageLogic.Result?) {
        let binding = makeBinding(result)
        return (sut: AsyncImageLogic(url: url, result: binding, store: store, loader: { _ in nil }), state: { binding.wrappedValue })
    }
}

