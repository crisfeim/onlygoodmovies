// © 2026  Cristian Felipe Patiño Rojas. Created on 15/1/26.
import XCTest
import SwiftUI
@testable import Movies

@MainActor
class ImageLoadFromRemoteUseCaseTests: XCTestCase, ImageLoadFromCacheUseCase {
    func test_initDoesntDeliverImage() {
        let (_, state) = makeSUT()
        XCTAssertTrue(isEmpty(state()))
    }
    
    func test_downloadDeliversErrorOnLoadingFailure() async {
        let (sut, state) = makeSUT() { _ in throw NSError(domain: "any-error", code: 0) }
        await sut.download()
        XCTAssertNotNil(state().error)
    }
    
    func test_downloadDeliversImageOnLoaderSuccess() async {
        let (sut, state) = makeSUT() { _ in  Image("") }
        await sut.download()
        XCTAssertEqual(state().image, Image(""))
    }
    
    func test_downloadDoesntLoadDataWhenExistentImage() async {
        nonisolated(unsafe) var loaderCalled = false
        let sut = ResourceImageCoordinator(phase: .empty, url: anyURL(), store: { _ in Image("existent image in store") }, loader: {
            _ in loaderCalled = true
            return nil
        })
        await sut.download()
        XCTAssertFalse(loaderCalled)
    }
   
    func makeSUT(url: URL? = anyURL(), _ phase: AsyncImagePhase = .empty, loader: @escaping ImagesLoader = { _ in nil }) -> (sut: ResourceImageCoordinator, state: () -> AsyncImagePhase) {
        let sut = ResourceImageCoordinator(phase: phase, url: url, store: { _ in nil }, loader: loader)
        return (sut: sut, state: { sut.phase })
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
