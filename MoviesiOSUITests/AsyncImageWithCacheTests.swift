// © 2026  Cristian Felipe Patiño Rojas. Created on 14/1/26.

import XCTest
import SwiftUI
import Movies


struct ImageCacheLogic {
    @Binding var cache: ImageCache
    let url: URL?
    let client: HTTPClient
    let mapper: (Data) -> UIImage?
    
    func loadImage() async {
       if let url, let (d, _) = try? await client(url), let image = mapper(d) {
            cache.cache(url, image)
        }
    }
}


class AsyncImageWithCacheTests: XCTestCase {
    func test_loadImageDoesntCachesOnFailure() async {
        var cache = ImageCache(countLimit: 1)
        let binding = Binding(get: { cache }, set: { cache = $0 })
        let url = URL(string: "https://any-url.com")!
        
        let sut = ImageCacheLogic(cache: binding, url: url, client: { _ in
            throw NSError(domain: "any-error", code: 0)
        }, mapper: {_  in UIImage() } )
        await sut.loadImage()
        XCTAssertNil(cache.get(url))
    }
    
    func test_loadImageCachesOnSuccess() async {
        var cache = ImageCache(countLimit: 1)
        let binding = Binding(get: { cache }, set: { cache = $0 })
        let url = URL(string: "https://any-url.com")!
        
        let sut = ImageCacheLogic(cache: binding, url: url, client: { _ in
            return (Data(), HTTPURLResponse())
        }, mapper: { _ in UIImage() })
        await sut.loadImage()
        XCTAssertNotNil(cache.get(url))
    }
}
