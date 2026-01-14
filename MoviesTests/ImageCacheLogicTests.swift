// © 2026  Cristian Felipe Patiño Rojas. Created on 14/1/26.

import XCTest
import SwiftUI
import Movies

@MainActor
class ImageCacheTests: XCTestCase {
    class Dummy {}
    func test_loadImageDoesntCachesOnFailure() async {
      
        var cache = ImageCache<Dummy>(countLimit: 1)
        let binding = Binding(get: { cache }, set: { cache = $0 })
        let url = URL(string: "https://any-url.com")!
        
        let sut = ImageCacheLogic(cache: binding, url: url, client: { _ in
            throw NSError(domain: "any-error", code: 0)
        }, mapper: {_  in Dummy() } )
        await sut.loadImage()
        XCTAssertNil(cache.get(url))
    }
    
    func test_loadImageCachesOnSuccess() async {
        var cache = ImageCache<Dummy>(countLimit: 1)
        let binding = Binding(get: { cache }, set: { cache = $0 })
        let url = URL(string: "https://any-url.com")!
        
        let sut = ImageCacheLogic(cache: binding, url: url, client: { _ in
            return (Data(), HTTPURLResponse())
        }, mapper: { _ in Dummy() })
        await sut.loadImage()
        XCTAssertNotNil(cache.get(url))
    }
}
