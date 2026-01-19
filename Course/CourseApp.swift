// © 2026  Cristian Felipe Patiño Rojas. Created on 3/1/26.

import Movies
import MoviesiOSUI
import SwiftUI

@main struct CourseApp: App {
    var body: some Scene {
        WindowGroup {
            #if DEBUG
               DebugApp()
            #else
               ProductionApp()
            #endif
        }
    }
}

// MARK: - Apps
#if DEBUG
struct DebugApp: View {
    @State var showConfiguration = false
    @State var loaderDelay = 3.5
    @State var imagesDelay = 3.5
    @State var cacheImages = false
    @State var id = UUID()
    var body: some View {
        MovieListComposer(
            loader: remoteLoader ~> withDelay | loaderDelay,
            thumbnail: { url in
                ResourceImage(
                    url: url,
                    store: cacheImages ? imagesCache.load : { _ in nil },
                    loader: imagesCache.download ~> withDelay | imagesDelay,
                    content: MovieThumbnail.init
                )
            }
        )
        .sheet(isPresented: $showConfiguration) {
            List {
                HStack {
                    Text("Loader Delay")
                    Slider(value: $loaderDelay)
                }
                
                HStack {
                    Text("Images Delay")
                    Slider(value: $imagesDelay)
                }
                .disabled(cacheImages)
                
                Toggle(isOn: $cacheImages) {
                    Text("Cache images")
                }
            }
        }
        .id(id)
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button(action: redraw) {
                    Image(systemName: "arrow.clockwise")
                }
            }
            
            ToolbarItem(placement: .bottomBar) {
                Button("Configuration") {
                    showConfiguration = true
                }
            }
        }
    }
    
    func redraw() { id = UUID() }
    
}
#endif

fileprivate struct ProductionApp: View {
    let imagesLoader: ImagesLoader = { url in
        let (d, _) = try await URLSession.shared.data(from: url)
        let scale = UITraitCollection.current.displayScale > 0 ? UITraitCollection.current.displayScale : 2.0
        let targetSize = CGSize(width: 40 * scale, height: 60 * scale)
        return UIImage(data: d)?.preparingThumbnail(of: targetSize).map { Image(uiImage: $0) }
    }
    
    var body: some View {
        MovieListComposer(
            loader: remoteLoader ~> withRetry | 1,
            thumbnail: AsyncImage<MovieThumbnail>.init
        )
    }
}

// MARK: - Dependencies

fileprivate let httpClient   = URLSessionHTTPClient(URLSession.shared)
fileprivate let remoteLoader = RemoteMoviesLoader(OnlyGoodMoviesApi.movies, httpClient)

fileprivate let imagesCache = {
    let imagesCachedSession = URLCachedSession(URLCache(
        memoryCapacity: 50*1024*1024,
        diskCapacity: 150*1024*1024,
        diskPath: "images"
    ))
    
    let downSampledImage: @Sendable (Data) -> Image? = { d in
        let scale = UITraitCollection.current.displayScale > 0 ? UITraitCollection.current.displayScale : 2.0
        let targetSize = CGSize(width: 40 * scale, height: 60 * scale)
        return UIImage(data: d)?.preparingThumbnail(of: targetSize).map { Image(uiImage: $0) }
    }
    
    let imagesLoader: @Sendable (URL) async throws -> Image? = { url in
        let d = try await imagesCachedSession.download(url)
        return downSampledImage(d)
    }

    let imagesStore: @Sendable (URL) -> Image? = { url in
        imagesCachedSession.retrieve(url).flatMap(downSampledImage)
    }

    return (load: imagesStore, download: imagesLoader)
}()


extension AsyncImage<MovieThumbnail> {
    init(_ url: URL?) {
        self.init(url: url, content: MovieThumbnail.init)
    }
}

// MARK: - Functional & Compositional helpers
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
nonisolated func withDelay<Param, Resource>( _ load: @escaping Loader<Param, Resource>, _ delay: TimeInterval) -> Loader<Param, Resource> {
    { param in
        try await Task.sleep(for: .seconds(delay))
        return try await load(param)
    }
}

nonisolated func withDelay<Resource>( _ load: @escaping Loader<Resource>, _ delay: TimeInterval) -> Loader<Resource> {
    { 
        try await Task.sleep(for: .seconds(delay))
        return try await load()
    }
}
#endif
