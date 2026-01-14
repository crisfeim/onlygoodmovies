// © 2026  Cristian Felipe Patiño Rojas. Created on 14/1/26.

import SwiftUI

public struct AsyncImageWithCache<Image: AnyObject, Fallback: View, Rendered: View>: View {
    let cache: NSURLCache<Image>
    let url: URL?
    let fallback: (URL?) -> Fallback
    let renderer: (Image) -> Rendered

    let client: HTTPClient
    let mapper: (Data) -> Image?
    
    public enum Content: View {
        case rendered(Rendered)
        case fallback(Fallback)

        @ViewBuilder
        public var body: some View {
            switch self {
            case .rendered(let view): view
            case .fallback(let view): view
            }
        }
    }
    
    public init(
        cache: NSURLCache<Image>,
        url: URL?,
        fallback: @escaping (URL?) -> Fallback,
        renderer: @escaping (Image) -> Rendered,
        client: @escaping HTTPClient,
        mapper: @escaping (Data) -> Image?,
        content: Content? = nil
    ) {
        self.cache = cache
        self.url = url
        self.fallback = fallback
        self.renderer = renderer
        self.client = client
        self.mapper = mapper
        self.content = content
    }
    
    @State var content: Content?
    public var body: some View {
        if let content { content }
        else {
            ProgressView()
                .task { content = await render() }
        }
            
    }
    
   public func loadImage() async {
        if let url, let (d, _) = try? await client(url), let image = mapper(d) {
            cache.cache(url, image)
        }
    }
   
    public func render() async -> Content {
        if let url, let image = cache.get(url) {
            return .rendered(renderer(image))
        } else {
            await loadImage()
            return .fallback(fallback(url))
        }
    }
}
