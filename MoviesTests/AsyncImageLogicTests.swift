import XCTest
import SwiftUI

@MainActor
class AsyncImageLogicTests: XCTestCase {
    
    struct AsyncImageLogic {
        let url: URL?
        @Binding var image: Image?
        let store: (URL) -> Image?
        func load() {
            guard image == nil, let url, let image = store(url) else { return }
            self.image = image
        }
    }
    
    func test_loadDoesntDeliverImageOnInit() {
        let binding = makeBinding(Optional<Image>.none)
        let _ = AsyncImageLogic(url: anyURL(), image: binding) { _  in nil }
        XCTAssertNil(binding.wrappedValue)
    }
    
    func test_loadDoesntDeliverImageOnEmptyStore() {
        let binding = makeBinding(Optional<Image>.none)
        let sut = AsyncImageLogic(url: anyURL(), image: binding, store: { _ in nil })
        sut.load()
        XCTAssertNil(binding.wrappedValue)
    }
    
    func test_loadDoesntDeliverImageIfURLDoesntMatchWhenNonEmptyStore() {
        let binding = makeBinding(Optional<Image>.none)
        let storage: [URL: Image] = [URL(string: "https://some-stored-url.com")!: Image("")]
        let sut = AsyncImageLogic(url: anyURL(), image: binding) { url in
            storage[url]
        }
        sut.load()
        XCTAssertNil(binding.wrappedValue)
    }
    
    func test_loadDeliversImageIfURLMatchesWithStoredImage() {
        let binding = makeBinding(Optional<Image>.none)
        let storage: [URL: Image] = [anyURL()!: Image("")]
        let sut = AsyncImageLogic(url: anyURL(), image: binding) { url in storage[url] }
        sut.load()
        XCTAssertNotNil(binding.wrappedValue)
    }
    
    func test_loadDoesntMessagesTheStoreIfImageIsAlreadySet() {
        let binding = makeBinding(Optional<Image>.some(Image("")))
        var storeCalled = false
        let sut = AsyncImageLogic(url: anyURL(), image: binding) { _ in
            storeCalled = true
            return Image("")
        }
        sut.load()
        XCTAssertFalse(storeCalled)
    }
}

fileprivate func anyURL() -> URL? {
    URL(string: "https://any-url.com")
}
