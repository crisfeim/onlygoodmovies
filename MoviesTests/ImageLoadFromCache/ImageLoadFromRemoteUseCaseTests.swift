// © 2026  Cristian Felipe Patiño Rojas. Created on 15/1/26.
import XCTest
import SwiftUI
import Movies

@MainActor
class ImageLoadFromRemoteUseCaseTests: XCTestCase {
    func test_initDoesntDeliverImage() {
        let (_, state) = makeSUT()
        XCTAssertNil(state())
    }
    
    func test_downloadDeliversErrorOnLoadingFailure() async {
        let (sut, state) = makeSUT() { _ in throw NSError(domain: "any-error", code: 0) }
        await sut.download()
        XCTAssertNotNil(state()?.error)
    }
    
    func test_downloadDeliversImageOnLoaderSuccess() async {
        let (sut, state) = makeSUT() { _ in  Image("") }
        await sut.download()
        XCTAssertEqual(try? state()?.get(), Image(""))
    }
    
    func test_downloadDoesntLoadDataWhenExistentImage() async {
        var loaderCalled = false
        let (sut, _) = makeSUT(.success(Image(""))) { _ in  loaderCalled = true ; return Image("")}
        await sut.download()
        XCTAssertFalse(loaderCalled)
    }
   
    func makeSUT(url: URL? = anyURL(), _ result: AsyncImageLogic.Result? = nil, loader: @escaping ImagesLoader = { _ in nil }) -> (sut: AsyncImageLogic, state: () -> AsyncImageLogic.Result?) {
        let binding = makeBinding(result)
        return (sut: AsyncImageLogic(url: url, result: binding, store: { _ in nil }, loader: loader), state: { binding.wrappedValue })
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
