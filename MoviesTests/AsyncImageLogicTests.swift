import XCTest
import SwiftUI

@MainActor
class AsyncImageLogicTests: XCTestCase {
    
    struct AsyncImageLogic {
        let url: URL?
        @Binding var image: Image?
        let store: (URL) -> Image?
        func load() {}
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
}

fileprivate func anyURL() -> URL? {
    URL(string: "https://any-url.com")
}
