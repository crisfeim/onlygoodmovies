// © 2026  Cristian Felipe Patiño Rojas. Created on 14/1/26.

import XCTest

import SwiftUI
import Movies

struct AsyncImageWithCache<Image: AnyObject, Rendered: View> {
    let cache: NSURLCache<Image>
    let url: URL?
    let fallback: (URL?) -> AsyncImage<Text>
    let renderer: (Image) -> Rendered

    let client: HTTPClient
    let mapper: (Data) -> Image?
   
    
    func loadImage() async {
        if let url, let (d, _) = try? await client(url), let image = mapper(d) {
            cache.cache(url, image)
        }
    }
    
    func render() {
        if let url, let image = cache.get(url) {
            _ = renderer(image)
        } else {
            _ = fallback(url)
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
    
    func test_renderDisplaysFallbackOnNonExistentImage() async {
        let url = URL(string: "https://www.google.com")!
        var fallbackCalled = false
        let fallback = { url in
            fallbackCalled = true
            return AsyncImage(url: url) { _ in
                Text("hello")
            }
        }
        let (sut, _) = makeSUT(url: url, fallback: fallback, client: { _ in (Data(), HTTPURLResponse()) })
        sut.render()
        XCTAssertTrue(fallbackCalled)
    }
    
    func test_renderDisplaysImageOnExistentImage() async {
        let url = URL(string: "https://www.google.com")!
        var rendererCalled = false
        let renderer = { (_: Dummy) in rendererCalled = true ; return Text("rendered") }
        let (sut, _) = makeSUT(url: url, renderer: renderer, client: { _ in (Data(), HTTPURLResponse()) })
        await sut.loadImage()
        sut.render()
        XCTAssertTrue(rendererCalled)
    }
    
    func makeSUT(
        url: URL,
        fallback: @escaping (URL?) -> AsyncImage<Text> = { url in AsyncImage(url: url) { _ in  Text("hello") } },
        renderer: @escaping (Dummy) -> Text = { _ in Text("rendered") },
        client: @escaping HTTPClient,
        mapper: @escaping (Data) -> Dummy? = anyMapper()
    ) -> (sut: AsyncImageWithCache<Dummy, Text>, cache: NSURLCache<Dummy>) {
        let cache = NSURLCache<Dummy>(countLimit: 1)
        let sut = AsyncImageWithCache<Dummy, Text>(
            cache: cache,
            url: url,
            fallback: fallback,
            renderer: renderer,
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
