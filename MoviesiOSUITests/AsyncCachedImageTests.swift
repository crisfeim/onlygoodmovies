// © 2026  Cristian Felipe Patiño Rojas. Created on 14/1/26.

import XCTest

import SwiftUI
import Movies

struct AsyncImageWithCache<Image: AnyObject> {
    let cache: NSURLCache<Image>
    let client: HTTPClient
    let mapper: (Data) -> Image?
    
    func loadImage(url: URL) async {
        if let (d, _) = try? await client(url), let image = mapper(d) {
            cache.cache(url, image)
        }
    }
}

class AsyncImageWithCacheTests: XCTestCase {
    func test_loadImageDoesntCachesDataOnRequestError() async {
        class Dummy {}
        let cache = NSURLCache<Dummy>(countLimit: 1)
        
        let sut = AsyncImageWithCache<Dummy>(
            cache: cache,
            client: { _ in throw NSError(domain: "any-error", code: 0) },
            mapper: { _ in Dummy() }
        )

        let url = URL(string: "https://www.google.com")!
        await sut.loadImage(url: url)
        XCTAssertNil(cache.get(url))
    }
    
    func test_loadImageCachesDataOnRequesSuccess() async {
        class Dummy {}
        let cache = NSURLCache<Dummy>(countLimit: 1)
        
        let sut = AsyncImageWithCache<Dummy>(
            cache: cache,
            client: { _ in (Data(), HTTPURLResponse()) },
            mapper: { _ in Dummy() }
        )

        let url = URL(string: "https://www.google.com")!
        await sut.loadImage(url: url)
        XCTAssertNotNil(cache.get(url))
    }
}
