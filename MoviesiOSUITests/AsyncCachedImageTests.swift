// © 2026  Cristian Felipe Patiño Rojas. Created on 14/1/26.

import XCTest

import SwiftUI
import Movies

struct AsyncImageWithCache<Image: AnyObject> {
    let cache: NSURLCache<Image>
    let url: URL?
    
    let client: HTTPClient
    let mapper: (Data) -> Image?
    
    
    func loadImage() async {
        if let url, let (d, _) = try? await client(url), let image = mapper(d) {
            cache.cache(url, image)
        }
    }
}

class AsyncImageWithCacheTests: XCTestCase {
    class Dummy {}
    
    func test_loadImageDoesntCachesDataOnRequestError() async {
        let url = URL(string: "https://www.google.com")!
        let (sut, cache) = makeSUT(url: url, client: { _ in throw anyError() })
        await sut.loadImage()
        XCTAssertNil(cache.get(url))
    }
    

    func test_loadImageCachesDataOnRequesSuccess() async {
        let url = URL(string: "https://www.google.com")!
        let (sut, cache) = makeSUT(url: url, client: { _ in (Data(), HTTPURLResponse()) })
        await sut.loadImage()
        XCTAssertNotNil(cache.get(url))
    }
    
    func makeSUT(url: URL, client: @escaping HTTPClient, mapper: @escaping (Data) -> Dummy? = anyMapper()) -> (sut: AsyncImageWithCache<Dummy>, cache: NSURLCache<Dummy>) {
        let cache = NSURLCache<Dummy>(countLimit: 1)
        let sut = AsyncImageWithCache<Dummy>(
            cache: cache,
            url: url,
            client: client,
            mapper: mapper
        )
        
        return (sut: sut, cache: cache)
    }
}


fileprivate func anyMapper() -> (Data) -> AsyncImageWithCacheTests.Dummy? {
    { _ in .init() }
}

fileprivate func anyError() -> Error {
    NSError(domain: "any-error", code: 0)
}
