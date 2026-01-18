// © 2026  Cristian Felipe Patiño Rojas. Created on 18/1/26.
import SwiftUI

public struct MoviesConfig: Equatable {
    public var reason: RedactionReasons
    public var modifier: Modifier
    
    public init(reason: RedactionReasons = [] , modifier: Modifier = .none) {
        self.reason = reason
        self.modifier = modifier
    }
}


public extension MoviesConfig {
    @MainActor
    static var loading = MoviesConfig(reason: .placeholder, modifier: .shimmer)
    
    @MainActor
    static var idle = MoviesConfig(reason: [], modifier: .none)
}


public enum Modifier {
    case shimmer
    case none
}
