// © 2026  Cristian Felipe Patiño Rojas. Created on 3/1/26.

import SwiftUI
import Core

// UI
@main struct CourseApp: App {
    var body: some Scene {
        WindowGroup {
           MoviesApp()
        }
    }
}

fileprivate struct MoviesApp: View {
    @State var state = MoviesState()
    
    var remoteLoader: MoviesLoader {
        { try await RemoteLoader.with(urlSessionHttpGetClient) }
    }

    var logic: MoviesLogic {
        .init(state: $state, loader: remoteLoader~>withRetry | 2)
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

struct MovieCell: View {
    let movie: Core.Movie
    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: movie.poster_url)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 40, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            VStack(alignment: .leading) {
                Text(movie.title)
                Text(movie.release_year.description)
                    .font(.footnote)
                    .opacity(0.5)
            }
        }
    }
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
    
    static var with: (HTTPGetClient) async throws -> [Core.Movie] {
        { get in
            let (d, r) = try await get(URL(string: "https://crisfe.im/apis/only-good-movies/v1")!)
            return try MoviesMapper.map(d, r)
        }
    }
}

fileprivate enum MoviesMapper {
    struct InvalidData: Error {}
    static let OK = 200
    static var map: (Data, HTTPURLResponse) throws -> [Core.Movie] {
        { d, r in
            guard r.statusCode == OK else { throw InvalidData() }
            return try JSONDecoder().decode([Core.Movie].self, from: d)
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
