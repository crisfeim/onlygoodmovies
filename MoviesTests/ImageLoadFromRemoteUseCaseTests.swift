// © 2026  Cristian Felipe Patiño Rojas. Created on 15/1/26.
import XCTest
import SwiftUI

@MainActor
class ImageLoadFromRemoteUseCaseTests: XCTestCase {
    func test_initDoesntDeliverImage() {
        let binding = makeBinding(Optional<AsyncImageLogic.Result>.none)
        let _ = makeSUT(binding: binding)
        XCTAssertNil(binding.wrappedValue)
    }
    
    func test_downloadDeliversErrorOnLoadingFailure() async {
        let binding = makeBinding(Optional<AsyncImageLogic.Result>.none)
        let sut = makeSUT(binding: binding) { _ in throw NSError(domain: "any-error", code: 0) }
        await sut.download()
        XCTAssertNotNil(binding.wrappedValue?.error)
    }
    
    func test_downloadDeliversImageOnLoaderSuccess() async {
        let binding = makeBinding(Optional<AsyncImageLogic.Result>.none)
        let sut = makeSUT(binding: binding) { _ in  Image("") }
        await sut.download()
        XCTAssertEqual(try? binding.wrappedValue?.get(), Image(""))
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

fileprivate extension Result {
    var error: Error? {
        switch self {
        case .failure(let e): return e
        default: return nil
        }
    }
}
