// © 2026  Cristian Felipe Patiño Rojas. Created on 14/1/26.

import XCTest

/*
 Solution
 
 - Uses underlying AsyncImage
 - If AsyncImage with success, caches image
 - Allows decoupling from solution
 - Handles memory pressure
 - Is functional, doesn't creates clasess
 */

/*
 
 CustomImage(url) ->
    Cache
    AsyncImage
 
 Cache
    Api:
        access() -> Cache
        get(url) -> UIImage?
        set(url)
    Limits
        100 images
        25mb
 */


import XCTest

class NSURLCacheTests: XCTestCase {
    
    class NSURLCache<Object: AnyObject> {
        private let cache: NSCache<NSURL, Object> = {
            let cache = NSCache<NSURL, Object>()
            cache.countLimit = 100
            cache.totalCostLimit = 25 * 1024 * 1024
            return cache
        }()
        
        func get(_ url: URL) -> Object? {
            cache.object(forKey: url as NSURL)
        }
        
        func cache(_ url: URL, _ value: Object) {
            cache.setObject(value, forKey: url as NSURL)
        }
    }
    
    func test_cache_storesAndRetrievesImage() {
        class Dummy { var some = "hello world" }
        let sut = NSURLCache<Dummy>()
        let url = URL(string: "https://any-url.com")!
        let image = Dummy()
        sut.cache(url, image)
        
        XCTAssertEqual(sut.get(url)?.some, "hello world")
    }
}
