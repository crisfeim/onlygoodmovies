// © 2026  Cristian Felipe Patiño Rojas. Created on 11/1/26.

import Foundation
import SwiftUI

fileprivate struct HTTPGetClient {
    typealias GetClosure = (URL) async throws -> (Data, URLResponse)
    let base: GetClosure
    var get: GetClosure {
        { try await base($0) }
    }
}

fileprivate typealias MoviesLoader = () async throws -> [Movie]

fileprivate struct MoviesComposition: View {
    let moviesLoader: MoviesLoader
    var retryableLoad: MoviesLoader { withRetry(moviesLoader) }
    @State private var movies: [Movie]?
    @State private var showError = false
    var showLoading: Bool { movies == nil }
    var showEmpty: Bool { movies != nil && movies!.isEmpty }

    var body: some View {
        MovieList(movies: movies ?? [], showLoading: showLoading, showEmpty: showEmpty, showError: showError) {
            showError = false
        }
        .task(load)
    }
    
    func load() async {
        do {
            movies = try await retryableLoad()
        } catch {
            showError = true
        }
    }
}

fileprivate struct RemoteLoader {
    let client: HTTPGetClient
    var load: () async throws -> [Movie] {
        {
            let (d, r) = try await client.get(URL(string: "https://crisfe.im/apis/only-good-movies/v1")!)
            return try Mapper.map(d, from: r)
        }
    }
}

fileprivate func withRetry<T>(attempts: Int = 3, _ load: @escaping () async throws -> T) -> () async throws -> T {
    {
        var attempts = attempts
        while true {
            do { return try await load() }
            catch { attempts += 1; if attempts >= 3 { throw error } }
        }
    }
}


fileprivate enum Mapper {
    static func map(_ data: Data, from response: URLResponse) throws -> [Movie] {
        try JSONDecoder().decode([Movie].self, from: data)
    }
}


fileprivate struct MovieList: View {
    let movies: [Movie]
    let showLoading: Bool
    let showEmpty: Bool
    let showError: Bool
    let onErrorTap: () -> Void
    var body: some View {
        List(movies, rowContent: Cell.init)
        .overlay { if showLoading { ProgressView() } }
        .overlay { if showEmpty { EmptyMoviesView() } }
        .toolbar { if showError { ErrorButton(action: onErrorTap) }
        }
    }
}


#Preview {
    MoviesComposition {
        [mockMovie()]
    }
}
