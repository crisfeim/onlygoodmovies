// © 2026  Cristian Felipe Patiño Rojas. Created on 14/1/26.

import XCTest
import Movies

class NSURLCacheTests: XCTestCase {
    
    func test_cache_storesAndRetrievesImage() {
        class Dummy { var some = "hello world" }
        let sut = ImageCache<Dummy>(countLimit: 1)
        let url = URL(string: "https://any-url.com")!
        let image = Dummy()
        sut.cache(url, image)
        
        XCTAssertEqual(sut.get(url)?.some, "hello world")
    }
    
    func test_cache_evictsOldestItemWhenReachingCountLimit() {
        let sut = ImageCache<NSObject>(countLimit: 1)
        let url1 = URL(string: "https://url1.com")!
        let url2 = URL(string: "https://url2.com")!
        let dummy1 = NSObject()
        let dummy2 = NSObject()
        
        sut.cache(url1, dummy1)
        sut.cache(url2, dummy2)
        
        XCTAssertNil(sut.get(url1), "First item should have been evicted")
        XCTAssertNotNil(sut.get(url2), "Second image should exist")
    }
}
