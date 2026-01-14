// © 2026  Cristian Felipe Patiño Rojas. Created on 14/1/26.
import Foundation
import UIKit

public final class ImageCache {
    let cache: NSCache<NSURL, UIImage>
    
    public init(countLimit: Int) {
        let cache = NSCache<NSURL, UIImage>()
        cache.countLimit = countLimit
        cache.totalCostLimit = 25 * 1024 * 1024
        self.cache = cache
    }
    
    public func get(_ url: URL) -> UIImage? {
        cache.object(forKey: url as NSURL)
    }
    
    public func cache(_ url: URL, _ value: UIImage) {
        cache.setObject(value, forKey: url as NSURL)
    }
}
