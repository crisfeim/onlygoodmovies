// © 2026  Cristian Felipe Patiño Rojas. Created on 18/1/26.
import SwiftUI

public struct MoviesConfig: Equatable {
    public var reason: RedactionReasons
    public var modifier: Modifier
    public var listDisabled: Bool
    
    public init(reason: RedactionReasons = [] , modifier: Modifier = .none, listDisabled: Bool = false) {
        self.reason = reason
        self.modifier = modifier
        self.listDisabled = listDisabled
    }
}


public extension MoviesConfig {
    @MainActor
    static var loading = MoviesConfig(reason: .placeholder, modifier: .shimmer, listDisabled: true)
    
    @MainActor
    static var idle = MoviesConfig(reason: [], modifier: .none, listDisabled: false)
}


public enum Modifier {
    case shimmer
    case none
}
