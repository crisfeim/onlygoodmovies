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
            MoviesListComposer(
                loader: remoteLoader ~> withRetry | 1 ,
                imagesLoader: imagesCache.download,
                imagesStore: imagesCache.load
            )
        }
    }
}


infix operator ~>: AdditionPrecedence
nonisolated func ~><First, Second>(lhs: First, rhs: (First) -> Second) -> Second { rhs(lhs) }

infix operator |: MultiplicationPrecedence
func | <Input, Argument, Output>(lhs: @escaping (Input, Argument) -> Output, rhs: Argument) -> (Input) -> Output {
    return { input in lhs(input, rhs) }
}

typealias Loader<Resource: Sendable> = @Sendable () async throws -> Resource
func withRetry<Resource>(_ load: @escaping Loader<Resource>, attempts: UInt) ->  Loader<Resource> {
    {
        var lastError: Error?
        for _ in 0...attempts {
            do { return try await load() }
            catch { lastError = error }
        }
        throw lastError!
    }
}
