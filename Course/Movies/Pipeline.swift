// © 2026  Cristian Felipe Patiño Rojas. Created on 6/1/26.

typealias Fetch<T: Sendable> = @Sendable () async throws -> T

struct Pipeline<T: Sendable> {
    let fetch: Fetch<T>
    
    init(_ fetch: @escaping Fetch<T>) {
        self.fetch = fetch
    }
    
    func handle(effects: @Sendable @escaping (T) -> Void) -> Pipeline<T> {
        Pipeline {
            let r = try await fetch()
            effects(r)
            return r
        }
    }
    
    func handle(effects: @Sendable @escaping (T) async -> Void) -> Pipeline {
        Pipeline {
            let r = try await fetch()
            Task.detached { await effects(r) }
            return r
        }
    }
    
    
    func map<B: Sendable>(_ transform: @Sendable @escaping (T) -> B) -> Pipeline<B> {
        Pipeline<B> {
            transform(try await fetch())
        }
    }
    
    func delay(for seconds: TimeInterval) -> Pipeline<T> {
        Pipeline {
            try await Task.sleep(for: .seconds(seconds))
            return try await fetch()
        }
    }
}


import Foundation
import Combine

class MovieService {
    struct MovieDTO { let id = UUID() }
    static func fetch() async -> [MovieDTO] {[]}
}


enum MovieMapper {
    static func map(remotes: [MovieService.MovieDTO]) -> [Movie] {
        remotes.map { _ in Movie(id: "", title: "", poster_url: "", release_year: 0) }
    }
}

fileprivate struct MovieList {
    let load: () async throws -> [Movie]
}

actor Cache {
    func save(_ movies: [Movie]) async {}
}

let cache = Cache()


extension Pipeline where T == [Movie] {
    func cache(with cache: Cache) -> Self {
        handle { movies in
            Task {
                await cache.save(movies)
            }
        }
    }
}

func make() {
    let list = MovieList(load:
        Pipeline(MovieService.fetch)
        .map(MovieMapper.map)
        .cache(with: cache)
        .fetch
    )
}
