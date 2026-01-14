// © 2026  Cristian Felipe Patiño Rojas. Created on 14/1/26.

import SwiftUI

@Observable public class EnvironmentImageCache {
    let cache: ImageCache<UIImage>
    public init(countLimit: Int) {
        cache = ImageCache(countLimit: countLimit)
    }
    
    public func cache(_ url: URL, _ value: UIImage) {
        cache.cache(url, value)
    }
    
    public func get(_ url: URL) -> UIImage? {
        cache.get(url)
    }
}
