// © 2026  Cristian Felipe Patiño Rojas. Created on 3/1/26.

import SwiftUI
import Movies
import MoviesiOSUI

fileprivate let httpClient   = URLSessionHTTPClient(URLSession.shared)
fileprivate let remoteLoader = RemoteMoviesLoader(OnlyGoodMoviesApi.movies, httpClient)
fileprivate let imagesLoader: (URL) async throws -> Image? = { url in
    let (d, _) = try await httpClient(url)
    return UIImage(data: d).map { Image(uiImage: $0) }
}

@main struct CourseApp: App {
    var body: some Scene {
        WindowGroup {
             MoviesUIComposer(loader: remoteLoader~>withRetry|2)
                .environment(\.imagesLoader, imagesLoader)
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


fileprivate typealias Loader<T: Sendable> = @Sendable () async throws -> T
fileprivate func withRetry<T>(_ load: @escaping Loader<T>, attempts: Int = 3) ->  Loader<T> {
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
