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
                loader: remoteLoader ~> withRetry | 1,
                imagesLoader: imagesCache.download ~> withDelay | 2.5 ~> withRetry | 1,
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

typealias Loader<each Param: Sendable, Resource: Sendable> = @Sendable (repeat each Param) async throws -> Resource

func withRetry<Param, Resource>(_ load: @escaping Loader<Param, Resource>, _ attempts: UInt) -> Loader<Param, Resource> {
    { param in try await retryLogic(attempts: attempts) { try await load(param) } }
}

func withRetry<Resource>(_ load: @escaping Loader<Resource>, _ attempts: UInt) -> Loader<Resource> {
    { try await retryLogic(attempts: attempts) { try await load() } }
}

private func retryLogic<R>(attempts: UInt, action: () async throws -> R) async throws -> R {
    var lastError: Error?
    for _ in 0...attempts {
        do { return try await action() }
        catch { lastError = error }
    }
    throw lastError!
}

#if DEBUG

func withDelay<Param, Resource>( _ load: @escaping Loader<Param, Resource>, _ delay: TimeInterval) -> Loader<Param, Resource> {
    { param in
        try await Task.sleep(for: .seconds(delay))
        return try await load(param)
    }
}
#endif
