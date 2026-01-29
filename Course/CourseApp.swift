// © 2026  Cristian Felipe Patiño Rojas. Created on 3/1/26.

import Movies
import MoviesiOSUI
import SwiftUI

struct CourseApp: App {
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

struct TestApp: SwiftUI.App {
    static var shared: Self!
    @State private var view: any View = EmptyView()
   
    func setView(_ newView : any View) {
        view = AnyView(newView.id(UUID()))
    }
    
    var body: some Scene {
        let _ = Self.shared = self
        WindowGroup { AnyView(view.id(UUID())) }
    }
}

// MARK: - Apps
#if DEBUG
struct DebugApp: View {
    @State var showConfiguration = false
    @State var network = NetworkScenario.wifi6
    @State var imagesDelay = 1.5
    @State var cacheImages = false
    @State var id = UUID()
    var body: some View {
        MovieListComposer(
            loader: remoteMoviesStream ~> withNetwork | network,
            thumbnail: { url in
                ResourceImage(
                    url: url,
                    store: cacheImages ? imagesCache.load : { _ in nil },
                    loader: imagesCache.download ~> withNetwork | network,
                    content: MovieThumbnail.init
                )
            }
        )
        .sheet(isPresented: $showConfiguration) {
            List {
                HStack {
                   
                    Picker("Select network conditions", selection: $network) {
                        
                        ForEach(NetworkScenario.allCases) { network in
                            Text(network.rawValue)
                        }
                        
                    }

                }
                
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
            loader: remoteMoviesStream,
            thumbnail: AsyncImage<MovieThumbnail>.init
        )
    }
}

// MARK: - Dependencies

fileprivate let httpClient   = URLSessionHTTPClient(URLSession.shared)

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

nonisolated func withDelay(_ stream: @escaping @Sendable () -> AsyncThrowingStream<Movie, Error>, _ delay: TimeInterval) -> @Sendable () -> AsyncThrowingStream<Movie, Error> {
    return {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    for try await movie in stream() {
                        try await Task.sleep(for: .seconds(delay))
                        continuation.yield(movie)
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            
            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }
}

nonisolated func withDelay<Resource>( _ load: @escaping Loader<Resource>, _ delay: TimeInterval) -> Loader<Resource> {
    { 
        try await Task.sleep(for: .seconds(delay))
        return try await load()
    }
}


nonisolated enum NetworkScenario: String, Sendable, CaseIterable, Identifiable {
    var id: Self { self }
    case edge
    case g3
    case g4
    case wifi6
    case tunnel
    
    var bandwidth: Double {
        switch self {
        case .edge:  return 20_000    // ~20 KB/s
        case .g3:    return 250_000   // ~250 KB/s
        case .g4:    return 5_000_000 // ~5 MB/s
        case .wifi6: return 50_000_000// ~50 MB/s
        case .tunnel: return 1_000    // Casi nada
        }
    }
    
    var latencyRange: ClosedRange<Double> {
        switch self {
        case .edge:  return 1.5...3.0
        case .g3:    return 0.3...0.8
        case .g4:    return 0.05...0.15
        default:     return 0.01...0.03
        }
    }
}

nonisolated func withNetwork(
    _ load: @escaping Loader<URL, Image?>,
    _ scenario: NetworkScenario
) -> Loader<URL, Image?> {
    { url in
        let latency = Double.random(in: scenario.latencyRange)
        try await Task.sleep(for: .seconds(latency))
        
        let image = try await load(url)
        let estimatedSize: Double = 120 * 180 * 0.5 // ~10.8 KB
        let transmissionTime = estimatedSize / scenario.bandwidth
        try await Task.sleep(for: .seconds(transmissionTime))
        
        return image
    }
}

func withNetwork(_ loader: @escaping @Sendable () -> AsyncThrowingStream<Movie, Error>, _ scenario: NetworkScenario) -> @Sendable () -> AsyncThrowingStream<Movie, Error> {
    
    nonisolated struct DTO: Encodable {
        let id: String
        let title: String
        let posterURL: String
        let releaseYear: Int
        
        init(movie: Movie) {
            self.id = movie.id
            self.title = movie.title
            self.posterURL = movie.posterURL
            self.releaseYear = movie.releaseYear
        }
    }
    return {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    let initialLatency = Double.random(in: scenario.latencyRange)
                    try await Task.sleep(for: .seconds(initialLatency))
                    
                    for try await item in loader() {
                        let data = try JSONEncoder().encode(DTO(movie: item))
                        let sizeInBytes = Double(data.count)
                        
                        let transmissionTime = sizeInBytes / scenario.bandwidth
                        let jitter = Double.random(in: 0...0.02)
                        
                        try await Task.sleep(for: .seconds(transmissionTime + jitter))
                        
                        continuation.yield(item)
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }
}

#endif
