// © 2026  Cristian Felipe Patiño Rojas. Created on 3/1/26.

import SwiftUI
import Core

// UI
@main struct CourseApp: App {
    var remoteLoader: MoviesLoader {
        { try await RemoteLoader.with(urlSessionHttpGetClient) }
    }
    
    var body: some Scene {
        WindowGroup {
            MoviesApp(loader: remoteLoader ~> withRetry|2)
        }
    }
}

fileprivate struct MoviesApp: View {
    @State var state = MoviesState()
    
    let loader: MoviesLoader

    var logic: MoviesLogic {
        .init(state: $state, loader: loader)
    }
    
    var body: some View {
        MovieList(state: $state)
            .environment(\.reload, logic.refresh)
            .task { await logic.load() }
    }
}


fileprivate struct MovieList: View {
    @Binding var state: MoviesState
    @Environment(\.reload) var reload
    
    var body: some View {
        List(state.movies, rowContent: MovieCell.init)
            .refreshable { await reload() }
            .overlay { if state.isLoading { ProgressView() } }
            .overlay { if state.showEmpty { EmptyMoviesView() } }
            .toolbar { if state.hasError { ErrorButton { state.hasError = false } }
        }
    }
}

extension EnvironmentValues {
    @Entry var reload: () async -> Void = {}
}

// Infrastructure

fileprivate typealias HTTPGetClient = @Sendable (URL) async throws -> (Data, HTTPURLResponse)

fileprivate var urlSessionHttpGetClient: HTTPGetClient {
    struct UnexpectedValuesRepresentation: Error {}
    return { url in
        let (d, r) = try await URLSession.shared.data(from: url)
        if let r = r as? HTTPURLResponse { return (d, r) }
        throw UnexpectedValuesRepresentation()
    }
}

fileprivate enum RemoteLoader {
    
    static var with: (HTTPGetClient) async throws -> [Movie] {
        { get in
            let (d, r) = try await get(URL(string: "https://crisfe.im/apis/only-good-movies/v1")!)
            return try MoviesMapper.map(d, r)
        }
    }
}

fileprivate enum MoviesMapper {
    struct InvalidData: Error {}
    static let OK = 200
    static var map: (Data, HTTPURLResponse) throws -> [Movie] {
        { d, r in
            guard r.statusCode == OK else { throw InvalidData() }
            return try JSONDecoder().decode([Movie].self, from: d)
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


// Previews

#Preview("App") {
    var shouldFail = false
    MoviesApp {
        try await Task.sleep(for: .seconds(1.5))

        if shouldFail {
            print("should fail")
            shouldFail = false
            throw anyError()
        } else {
            print("should not fail")
            shouldFail = true
            return [mockMovie(), mockMovie()]
        }
    }
}

#if DEBUG
fileprivate extension MoviesState {
    static func loading() -> Self {
        .init(
            movies: [],
            isLoading: true,
            hasError: false,
            showEmpty: false
        )
    }
    
    static func loaded() -> Self {
        .init(
            movies: [mockMovie(), mockMovie()],
            isLoading: false,
            hasError: false,
            showEmpty: false
        )
    }
    
    static func loadedWithError() -> Self {
        .init(
            movies: [mockMovie(), mockMovie()],
            isLoading: false,
            hasError: true,
            showEmpty: false
        )
    }
    
    static func error() -> Self {
        .init(
            movies: [],
            isLoading: false,
            hasError: true,
            showEmpty: false
        )
    }
    
    static func empty() -> Self {
        .init(
            movies: [],
            isLoading: false,
            hasError: false,
            showEmpty: true
        )
    }
}
#endif


#Preview("Loading") {
    @Previewable @State var state = MoviesState()
    MovieList(state: $state)
}

#Preview("Loaded") {
    @Previewable @State var state = MoviesState.loaded()
    MovieList(state: $state)
}

#Preview("Empty") {
    @Previewable @State var state = MoviesState.empty()
    MovieList(state: $state)
}

#Preview("Error") {
    @Previewable @State var state = MoviesState.error()
    MovieList(state: $state)
}

#Preview("Loaded + Error") {
    @Previewable @State var state = MoviesState.loadedWithError()
    MovieList(state: $state)
}
