// © 2026  Cristian Felipe Patiño Rojas. Created on 15/1/26.

import SwiftUI
import XCTest

protocol ImageLoadTestCase: XCTestCase  {}
extension ImageLoadTestCase {
    func isEmpty(_ phase: AsyncImagePhase) -> Bool {
        if case .empty = phase { return true }
        return false
    }
}
