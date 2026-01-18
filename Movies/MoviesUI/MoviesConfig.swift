// © 2026  Cristian Felipe Patiño Rojas. Created on 18/1/26.
import SwiftUI

public struct MoviesConfig: Equatable {
    public var reason: RedactionReasons = []
    
    public init(reason: RedactionReasons = []) {
        self.reason = reason
    }
}
