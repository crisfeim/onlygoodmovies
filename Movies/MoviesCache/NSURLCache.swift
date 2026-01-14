// © 2026  Cristian Felipe Patiño Rojas. Created on 14/1/26.
import Foundation

public class NSURLCache<Object: AnyObject> {
    private let cache: NSCache<NSURL, Object> = {
        let cache = NSCache<NSURL, Object>()
        cache.totalCostLimit = 25 * 1024 * 1024
        return cache
    }()
    
    public init(countLimit: Int) {
        cache.countLimit = countLimit
    }
    
    public func get(_ url: URL) -> Object? {
        cache.object(forKey: url as NSURL)
    }
    
    public func cache(_ url: URL, _ value: Object) {
        cache.setObject(value, forKey: url as NSURL)
    }
}
