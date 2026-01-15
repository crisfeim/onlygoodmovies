import XCTest
import SwiftUI

@MainActor
class AsyncImageLogicTests: XCTestCase {
    
    struct AsyncImageLogic {
        @Binding var image: Image?
        let store: (URL) -> Image?
        func load() {}
    }
    
    func test_loadDoesntDeliverImageOnInit() {
        let binding = makeBinding(Optional<Image>.none)
        let _ = AsyncImageLogic(image: binding) { _  in nil } 
        XCTAssertNil(binding.wrappedValue)
    }
    
    func test_loadDoesntDeliverImageOnEmptyStore() {
        let binding = makeBinding(Optional<Image>.none)
        let sut = AsyncImageLogic(image: binding, store: { _ in nil })
        sut.load()
        XCTAssertNil(binding.wrappedValue)
    }
}
