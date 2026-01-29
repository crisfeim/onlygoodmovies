// © 2026  Cristian Felipe Patiño Rojas. Created on 29/1/26.

import Combine
import SwiftUI
import Movies
extension Publisher {
    func enumerated() -> AnyPublisher<(Int, Output), Failure> {
        scan(nil) { acc, next in
            (acc.map { $0.0 + 1 } ?? 0, next)
        }
        .compactMap { $0 }
        .eraseToAnyPublisher()
    }
}

protocol StateRegistrator {
    var registeredState: Any {get}
}


extension View {
    static var bodyEvaluationNotification: Notification.Name {
        Notification.Name("bodyEvaluationNotification_\(String(describing: Self.self))")
    }
    
    var bodyAssertion: Bool {
        #if DEBUG
        if NSClassFromString("XCTestCase") != nil {
            ensureStateDependencyRegistration()
            Self._printChanges()
            NotificationCenter.default.post(name: Self.bodyEvaluationNotification, object: self)
        }
        #endif
        return true
    }
    
    private func ensureStateDependencyRegistration() {
        _ = (self as? StateRegistrator)?.registeredState
    }
    
    static func bodyEvaluations() -> AsyncPublisher<AnyPublisher<(Int, Self), Never>> {
        NotificationCenter.default
            .publisher(for: bodyEvaluationNotification)
            .compactMap { $0.object as? Self }
            .enumerated().values
    }
}

