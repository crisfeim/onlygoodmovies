import XCTest
import SwiftUI

@MainActor
class ImageLoadFromCacheUseCaseTests: XCTestCase {
    
    func test_initDoesntDeliverImage() {
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
        XCTAssertNotNil(binding.wrappedValue)
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


typealias ImagesStore = (URL) -> Image?
typealias ImagesLoader = (URL) async throws -> Image?

struct AsyncImageLogic {
    typealias Result = Swift.Result<Image, Error>
    struct ImageDecodingError: Error {}
    let url: URL?
    @Binding var result: Result?
    let store: ImagesStore
    let loader: ImagesLoader
    func load() {
        guard result == nil, let url, let image = store(url) else { return }
        self.result = .success(image)
    }
    
    func download() async {
        guard let url, result == nil else { return }
        do {
            guard let image = try await loader(url) else {
                result = .failure(ImageDecodingError())
                return
            }
            result = .success(image)
        } catch {
            
        }
      
    }
}

@MainActor
class ImageLoadFromRemoteUseCaseTests: XCTestCase {
    func test_initDoesntDeliverImage() {
        let binding = makeBinding(Optional<AsyncImageLogic.Result>.none)
        let _ = makeSUT(binding: binding)
        XCTAssertNil(binding.wrappedValue)
    }
    
    func test_downloadDoesntDeliversErrorOnLoadingFailure() async {
        let binding = makeBinding(Optional<AsyncImageLogic.Result>.none)
        let sut = makeSUT(binding: binding) { _ in throw NSError(domain: "any-error", code: 0) }
        await sut.download()
        XCTAssertNil(binding.wrappedValue)
    }
    
    func test_downloadDeliversImageOnLoaderSuccess() async {
        let binding = makeBinding(Optional<AsyncImageLogic.Result>.none)
        let sut = makeSUT(binding: binding) { _ in  Image("") }
        await sut.download()
        XCTAssertNotNil(binding.wrappedValue)
    }
    
    func test_downloadDoesntLoadDataWhenExistentImage() async {
        let binding = makeBinding(Optional<AsyncImageLogic.Result>.some(.success(Image(""))))
        var loaderCalled = false
        let sut = makeSUT(binding: binding) { _ in  loaderCalled = true ; return Image("")}
        await sut.download()
        XCTAssertFalse(loaderCalled)
    }
   
    func makeSUT(url: URL? = anyURL(), binding: Binding<Result<Image, Error>?>, loader: @escaping ImagesLoader = { _ in nil }) -> AsyncImageLogic {
        AsyncImageLogic(url: url, result: binding, store: { _ in nil }, loader: loader)
    }
}

fileprivate func anyURL() -> URL? {
    URL(string: "https://any-url.com")
}
