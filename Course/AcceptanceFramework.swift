// © 2026  Cristian Felipe Patiño Rojas. Created on 29/1/26.

import Combine
import SwiftUI
extension Publisher {
    func enumerated() -> AnyPublisher<(Int, Output), Failure> {
        scan(nil) { acc, next in
            (acc.map { $0.0 + 1 } ?? 0, next)
        }
        .compactMap { $0 }
        .eraseToAnyPublisher()
    }
}



class ViewStorage {
    static var shared = ViewStorage()
    private var history: [String: [Any]] = [:]
    
    func append<T>(_ view: T) {
        let key = String(describing: T.self)
        history[key, default: []].append(view)
    }
    
    func getHistory<T>(for type: T.Type) -> [T] {
        let key = String(describing: type)
        return (history[key] as? [T]) ?? []
    }
    
    func reset() {
        history = [:]
    }
}

extension View {
    static var bodyEvaluationNotification: Notification.Name {
        Notification.Name("bodyEvaluationNotification_\(String(describing: Self.self))")
    }
    
    var historyAssertion: Bool {
        #if DEBUG
        if NSClassFromString("XCTestCase") != nil {
            ViewStorage.shared.append(self)
        }
        #endif
        return true
    }
    
    var bodyAssertion: Bool {
        #if DEBUG
        if NSClassFromString("XCTestCase") != nil {
            Self._printChanges()
            NotificationCenter.default.post(name: Self.bodyEvaluationNotification, object: self)
        }
        #endif
        return true
    }
    
    static func bodyEvaluations() -> AsyncPublisher<AnyPublisher<(Int, Self), Never>> {
        NotificationCenter.default
            .publisher(for: bodyEvaluationNotification)
            .compactMap { $0.object as? Self }
            .enumerated().values
    }
}

