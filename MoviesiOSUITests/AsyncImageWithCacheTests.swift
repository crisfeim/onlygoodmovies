// © 2026  Cristian Felipe Patiño Rojas. Created on 14/1/26.

import XCTest
import SwiftUI
import Movies


@MainActor
struct ImageCacheLogic {
    @Binding var cache: ImageCache
    let url: URL?
    let client: HTTPClient
    
    func loadImage() async {
       if let url, let (d, _) = try? await URLSession.shared.data(from: url), let image = UIImage(data: d) {
            cache.cache(url, image)
        }
    }
}


@MainActor
class AsyncImageWithCacheTests: XCTestCase {
    func test_loadImageDoesntCachesOnFailure() async {
        var cache = ImageCache(countLimit: 1)
        let binding = Binding(get: { cache }, set: { cache = $0 })
        let url = URL(string: "https://any-url.com")!
        
        let sut = ImageCacheLogic(cache: binding, url: url, client: { _ in
            throw NSError(domain: "any-error", code: 0)
        })
        await sut.loadImage()
        XCTAssertNil(cache.get(url))
    }
}
