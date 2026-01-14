// © 2026  Cristian Felipe Patiño Rojas. Created on 14/1/26.


import XCTest
import SwiftUI
import Movies

public struct ImageCacheLogic {
    @Binding var cache: ImageCache
    let url: URL?
    let client: HTTPClient
    let mapper: (Data) -> UIImage?
    
    public init(cache: Binding<ImageCache>, url: URL?, client: @escaping HTTPClient, mapper: @escaping (Data) -> UIImage?) {
        self._cache = cache
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
