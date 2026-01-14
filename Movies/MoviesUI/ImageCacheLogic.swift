// © 2026  Cristian Felipe Patiño Rojas. Created on 14/1/26.

import SwiftUI

public struct ImageCacheLogic<Image: AnyObject> {
    let cache: ImageCache<Image>
    let url: URL?
    let client: HTTPClient
    let mapper: (Data) -> Image?
    
    public init(cache: ImageCache<Image>, url: URL?, client: @escaping HTTPClient, mapper: @escaping (Data) -> Image?) {
        self.cache = cache
        self.url = url
        self.client = client
        self.mapper = mapper
    }
    
    public func loadImage() async {
       if let url, let (d, _) = try? await client(url), let image = mapper(d) {
            cache.cache(url, image)
        }
    }
}
