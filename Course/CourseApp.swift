// © 2026  Cristian Felipe Patiño Rojas. Created on 3/1/26.

import SwiftUI
import Core

// UI
@main struct CourseApp: App {
    var remoteLoader: MoviesLoader {
        { try await RemoteLoader(urlSessionHTTPClient) }
    }
    
    var body: some Scene {
        WindowGroup {
            MoviesUIComposer(loader: remoteLoader ~> withRetry|2)
        }
    }
}

// Composition Decorators & Functional helpers
infix operator ~>: AdditionPrecedence
func ~> <T, V>(lhs: T, rhs: (T) -> V) -> V { rhs(lhs) }

infix operator |: MultiplicationPrecedence
func | <T, U, V>(lhs: @escaping (T, U) -> V, rhs: U) -> (T) -> V {
    return { T in lhs(T, rhs) }
}


fileprivate func withRetry<T>(_ load: @escaping () async throws -> T, attempts: Int = 3) -> () async throws -> T {
    {
        var lastError: Error?
        for _ in 0..<attempts {
            do {
                return try await load()
            } catch {
                lastError = error
            }
        }
        throw lastError!
    }
}
