// © 2026  Cristian Felipe Patiño Rojas. Created on 14/1/26.

import XCTest

import SwiftUI
import Movies

struct AsyncImageWithCache<Image: AnyObject, Fallback: View, Rendered: View>: View {
    let cache: NSURLCache<Image>
    let url: URL?
    let fallback: (URL?) -> Fallback
    let renderer: (Image) -> Rendered

    let client: HTTPClient
    let mapper: (Data) -> Image?
    
    enum Content: View {
        case rendered(Rendered)
        case fallback(Fallback)

        @ViewBuilder
        var body: some View {
            switch self {
            case .rendered(let view): view
            case .fallback(let view): view
            }
        }
    }
    
    @State var content: Content?
    var body: some View {
        if let content { content }
        else {
            ProgressView()
                .task { content = await render() }
        }
            
    }
    
    func loadImage() async {
        if let url, let (d, _) = try? await client(url), let image = mapper(d) {
            cache.cache(url, image)
        }
    }
   
    func render() async -> Content {
        if let url, let image = cache.get(url) {
            return .rendered(renderer(image))
        } else {
            await loadImage()
            return .fallback(fallback(url))
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
        _ = await sut.render()
        XCTAssertTrue(fallbackCalled)
    }
    
    func test_renderDisplaysImageOnExistentImage() async {
        let url = URL(string: "https://www.google.com")!
        var rendererCalled = false
        let renderer = { (_: Dummy) in rendererCalled = true ; return Text("rendered") }
        let (sut, _) = makeSUT(url: url, renderer: renderer, client: { _ in (Data(), HTTPURLResponse()) })
        await sut.loadImage()
        _ = await sut.render()
        XCTAssertTrue(rendererCalled)
    }
    
    func test_renderCachesImageOnNonExistentImage() async {
        let url = URL(string: "https://www.google.com")!
        let (sut, cache) = makeSUT(url: url, client: { _ in (Data(), HTTPURLResponse()) })
        _ = await sut.render()
        XCTAssertNotNil(cache.get(url))
    }
    
    func makeSUT(
        url: URL,
        fallback: @escaping (URL?) -> AsyncImage<Text> = { url in AsyncImage(url: url) { _ in  Text("hello") } },
        renderer: @escaping (Dummy) -> Text = { _ in Text("rendered") },
        client: @escaping HTTPClient,
        mapper: @escaping (Data) -> Dummy? = anyMapper()
    ) -> (sut: AsyncImageWithCache<Dummy, AsyncImage<Text>, Text>, cache: NSURLCache<Dummy>) {
        let cache = NSURLCache<Dummy>(countLimit: 1)
        let sut = AsyncImageWithCache<Dummy, AsyncImage<Text>, Text>(
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
