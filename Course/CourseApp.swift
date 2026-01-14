// © 2026  Cristian Felipe Patiño Rojas. Created on 3/1/26.

import SwiftUI
import Movies
import MoviesiOSUI

// UI
@main struct CourseApp: App {
    let httpClient = URLSessionHTTPClient(URLSession.shared)
    
    var remoteLoader: MoviesLoader {
        RemoteMoviesLoader(OnlyGoodMoviesApi.movies, httpClient)
    }
    
    var body: some Scene {
        WindowGroup {
            MoviesUIComposer(loader: remoteLoader)
                .environment(\.imageRenderer, imageRenderer)
        }
    }
    
    private let cache = NSURLCache<UIImage>(countLimit: 50)
    func imageRenderer(_ url: URL?) -> AsyncImageWithCache {
        AsyncImageWithCache(
            cache: cache,
            url: url,
            mapper: UIImage.init(data:)
        )
    }
}

// Composition Decorators & Functional helpers
infix operator ~>: AdditionPrecedence
func ~> <T, V>(lhs: T, rhs: (T) -> V) -> V { rhs(lhs) }

infix operator |: MultiplicationPrecedence
func | <T, U, V>(lhs: @escaping (T, U) -> V, rhs: U) -> (T) -> V {
    return { T in lhs(T, rhs) }
}


fileprivate typealias Load<T> = () async throws -> T
fileprivate func withRetry<T>(_ load: @escaping Load<T>, attempts: Int = 3) ->  Load<T> {
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
