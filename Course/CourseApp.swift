// © 2026  Cristian Felipe Patiño Rojas. Created on 3/1/26.

import SwiftUI
import Movies
import MoviesiOSUI


fileprivate let httpClient   = URLSessionHTTPClient(URLSession.shared)
fileprivate let remoteLoader = RemoteMoviesLoader(OnlyGoodMoviesApi.movies, httpClient)

fileprivate let imagesCache = {
    let imagesCachedSession = URLCachedSession(URLCache(
        memoryCapacity: 50*1024*1024,
        diskCapacity: 150*1024*1024,
        diskPath: "images"
    ))
    
    let imagesLoader: @Sendable (URL) async throws -> Image? = { url in
        let d = try await imagesCachedSession.download(url)
        return UIImage(data: d).map { Image(uiImage: $0) }
    }

    let imagesStore: @Sendable (URL) -> Image? = { url in
        imagesCachedSession.retrieve(url).flatMap { data in
            UIImage(data: data).map { Image(uiImage: $0) }
        }
    }

    return (load: imagesStore, download: imagesLoader)
}()

@main struct CourseApp: App {
    var body: some Scene {
        WindowGroup {
            MoviesUIComposer(loader: remoteLoader --> withRetry | 1)
                .environment(\.imagesLoader, imagesCache.download)
                .environment(\.imagesStore, imagesCache.load)
        }
    }
}


infix operator -->: AdditionPrecedence
nonisolated func --><T, V>(lhs: T, rhs: (T) -> V) -> V { rhs(lhs) }

infix operator |: MultiplicationPrecedence
func | <T, U, V>(lhs: @escaping (T, U) -> V, rhs: U) -> (T) -> V {
    return { T in lhs(T, rhs) }
}

 typealias Loader<T: Sendable> = @Sendable () async throws -> T
func withRetry<T>(_ load: @escaping Loader<T>, attempts: UInt) ->  Loader<T> {
    {
        var lastError: Error?
        for _ in 0...attempts {
            do { return try await load() }
            catch { lastError = error }
        }
        throw lastError!
    }
}
