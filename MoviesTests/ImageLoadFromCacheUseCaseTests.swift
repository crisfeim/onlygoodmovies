import XCTest
import SwiftUI

@MainActor
class ImageLoadFromCacheUseCaseTests: XCTestCase {
    
    func test_initDoesntDeliverImage() {
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
        AsyncImageLogic(url: url, image: image, store: store, loader: { _ in nil })
    }
}


typealias ImagesStore = (URL) -> Image?
typealias ImagesLoader = (URL) async throws -> Image?

struct AsyncImageLogic {
    let url: URL?
    @Binding var image: Image?
    let store: ImagesStore
    let loader: ImagesLoader
    func load() {
        guard image == nil, let url, let image = store(url) else { return }
        self.image = image
    }
    
    func download() async {
        guard let url, image == nil else { return }
        image = try? await loader(url)
    }
}

@MainActor
class ImageLoadFromRemoteUseCaseTests: XCTestCase {
    func test_initDoesntDeliverImage() {
        let binding = makeBinding(Optional<Image>.none)
        let _ = makeSUT(image: binding)
        XCTAssertNil(binding.wrappedValue)
    }
    
    func test_downloadDoesntDeliversImageOnLoadingFailure() async {
        let binding = makeBinding(Optional<Image>.none)
        let sut = makeSUT(image: binding) { _ in throw NSError(domain: "any-error", code: 0) }
        await sut.download()
        XCTAssertNil(binding.wrappedValue)
    }
    
    func test_downloadDeliversImageOnLoaderSuccess() async {
        let binding = makeBinding(Optional<Image>.none)
        let sut = makeSUT(image: binding) { _ in  Image("") }
        await sut.download()
        XCTAssertNotNil(binding.wrappedValue)
    }
    
    func test_downloadDoesntLoadDataWhenExistentImage() async {
        let binding = makeBinding(Optional<Image>.some(Image("")))
        var loaderCalled = false
        let sut = makeSUT(image: binding) { _ in  loaderCalled = true ; return Image("")}
        await sut.download()
        XCTAssertFalse(loaderCalled)
    }
    
    
   
    func makeSUT(url: URL? = anyURL(), image: Binding<Image?>, loader: @escaping ImagesLoader = { _ in nil }) -> AsyncImageLogic {
        AsyncImageLogic(url: url, image: image, store: { _ in nil }, loader: loader)
    }
}

fileprivate func anyURL() -> URL? {
    URL(string: "https://any-url.com")
}
