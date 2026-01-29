// © 2026  Cristian Felipe Patiño Rojas. Created on 13/1/26.
import Foundation

public var RemoteMoviesLoader: (URL, @escaping HTTPClient) -> () async throws -> [Movie] {
   return { url, get in
       {
           let (d, r) = try await get(url)
           return try MoviesMapper.map(d, r)
       }
   }
}

public var remoteMoviesStream: @Sendable () -> AsyncThrowingStream<Movie, Error> {
    return {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    let url = URL(string: "https://crisfe.im/apis/only-good-movies/v2/")!
                    let stream = try await URLSession.shared.bytes(from: url).0.lines
                        .map { Data($0.utf8) }
                        .map { try? MoviesMapper.decode(Data($0)) }
                        .compactMap { $0 }
                    
                    for try await movie in stream {
                        if Task.isCancelled { break }
                        continuation.yield(movie)
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in  task.cancel() }
        }
    }
}

