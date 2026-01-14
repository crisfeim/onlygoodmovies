// © 2026  Cristian Felipe Patiño Rojas. Created on 14/1/26.

import SwiftUI

public struct AsyncImageWithCache: View {
    let cache: NSURLCache<UIImage>
    let url: URL?
    let client: HTTPClient
    let mapper: (Data) -> UIImage?
    
    public init(cache: NSURLCache<UIImage>, url: URL?, client: @escaping HTTPClient, mapper: @escaping (Data) -> UIImage?) {
        self.cache = cache
        self.url = url
        self.client = client
        self.mapper = mapper
    }
    
    public var body: some View {
        if let url, let image = cache.get(url) {
            Image(uiImage: image)
        } else {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image.task { await loadImage() }
                default: ProgressView()
               }
            }
        }
    }
    
   public func loadImage() async {
        if let url, let (d, _) = try? await client(url), let image = mapper(d) {
            cache.cache(url, image)
        }
    }
}

