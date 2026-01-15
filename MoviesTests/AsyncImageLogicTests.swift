import XCTest
import SwiftUI

@MainActor
class AsyncImageLogicTests: XCTestCase {
    
    typealias ImagesStore = (URL) -> Image?
    
    struct AsyncImageLogic {
        let url: URL?
        @Binding var image: Image?
        let store: ImagesStore
        func load() {
            guard image == nil, let url, let image = store(url) else { return }
            self.image = image
        }
    }
    
    func test_loadDoesntDeliverImageOnInit() {
        let binding = makeBinding(Optional<Image>.none)
        let _ = makeSUT(image: binding)
        XCTAssertNil(binding.wrappedValue)
    }
    
    func test_loadDoesntDeliverImageOnEmptyStore() {
        let binding = makeBinding(Optional<Image>.none)
        let sut =  makeSUT(image: binding)
        sut.load()
        XCTAssertNil(binding.wrappedValue)
    }
    
    func test_loadDoesntDeliverImageIfURLDoesntMatchWhenNonEmptyStore() {
        let binding = makeBinding(Optional<Image>.none)
        let sut = makeSUT(image: binding) { url in
            if url != URL(string: "https://stored.com") { return nil }
            return Image("")
        }
        sut.load()
        XCTAssertNil(binding.wrappedValue)
    }
    
    func test_loadDeliversImageIfURLMatchesWithStoredImage() {
        let binding = makeBinding(Optional<Image>.none)
        let sut = makeSUT(image: binding) { url in url == anyURL()! ? Image("") : nil }
        sut.load()
        XCTAssertNotNil(binding.wrappedValue)
    }
    
    func test_loadDoesntMessagesTheStoreIfImageIsAlreadySet() {
        let binding = makeBinding(Optional<Image>.some(Image("")))
        var storeCalled = false
        let sut = makeSUT(image: binding) { _ in
            storeCalled = true
            return Image("")
        }
        sut.load()
        XCTAssertFalse(storeCalled)
    }
    
    func makeSUT(url: URL? = anyURL(), image: Binding<Image?>, store: @escaping ImagesStore = { _ in nil }) -> AsyncImageLogic {
        AsyncImageLogic(url: url, image: image, store: store)
    }
}

fileprivate func anyURL() -> URL? {
    URL(string: "https://any-url.com")
}
