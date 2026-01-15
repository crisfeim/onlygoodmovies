import XCTest
import SwiftUI

@MainActor
class AsyncImageLogicTests: XCTestCase {
    
    struct AsyncImageLogic {
        @Binding var image: Image?
        func load() {}
    }
    
    func test_loadDoesntDeliverImageOnInit() {
        let binding = makeBinding(Optional<Image>.none)
        let _ = AsyncImageLogic(image: binding)
        XCTAssertNil(binding.wrappedValue)
    }
}
