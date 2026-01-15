import XCTest
import SwiftUI

@MainActor
class ImageLoadFromCacheUseCaseTests: XCTestCase {
    
    func test_initDoesntDeliverResult() {
        let binding = makeBinding(Optional<AsyncImageLogic.Result>.none)
        let _ = makeSUT(binding: binding)
        XCTAssertNil(binding.wrappedValue)
    }
    
    func test_loadDoesntDeliverImageOnEmptyStore() {
        let binding = makeBinding(Optional<AsyncImageLogic.Result>.none)
        let sut =  makeSUT(binding: binding)
        sut.load()
        XCTAssertNil(binding.wrappedValue)
    }
    
    func test_loadDoesntDeliverImageIfURLDoesntMatchWhenNonEmptyStore() {
        let binding = makeBinding(Optional<AsyncImageLogic.Result>.none)
        let sut = makeSUT(binding: binding) { url in
            if url != URL(string: "https://stored.com") { return nil }
            return Image("")
        }
        sut.load()
        XCTAssertNil(binding.wrappedValue)
    }
    
    func test_loadDeliversImageIfURLMatchesWithStoredImage() {
        let binding =  makeBinding(Optional<AsyncImageLogic.Result>.none)
        let sut = makeSUT(binding: binding) { url in url == anyURL()! ? Image("") : nil }
        sut.load()
        XCTAssertEqual(try? binding.wrappedValue?.get(), Image(""))
    }
    
    func test_loadDoesntMessagesTheStoreIfImageIsAlreadySet() {
        let binding =  makeBinding(Optional<AsyncImageLogic.Result>.some(.success(Image(""))))
        var storeCalled = false
        let sut = makeSUT(binding: binding) { _ in
            storeCalled = true
            return Image("")
        }
        sut.load()
        XCTAssertFalse(storeCalled)
    }
    
    func makeSUT(url: URL? = anyURL(), binding: Binding<AsyncImageLogic.Result?>, store: @escaping ImagesStore = { _ in nil }) -> AsyncImageLogic {
        AsyncImageLogic(url: url, result: binding, store: store, loader: { _ in nil })
    }
}

