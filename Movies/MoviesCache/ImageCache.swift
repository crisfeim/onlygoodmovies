// © 2026  Cristian Felipe Patiño Rojas. Created on 14/1/26.
import Foundation

public final class ImageCache<Image: AnyObject> {
    let cache: NSCache<NSURL, Image>
    
    public init(countLimit: Int) {
        let cache = NSCache<NSURL, Image>()
        cache.countLimit = countLimit
        cache.totalCostLimit = 25 * 1024 * 1024
        self.cache = cache
    }
    
    public func get(_ url: URL) -> Image? {
        cache.object(forKey: url as NSURL)
    }
    
    public func cache(_ url: URL, _ value: Image) {
        cache.setObject(value, forKey: url as NSURL)
    }
}
