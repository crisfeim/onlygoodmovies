// © 2026  Cristian Felipe Patiño Rojas. Created on 16/1/26.
import Foundation

typealias CachedSession = (
    download: @Sendable (URL) async throws -> Data,
    retrieve: @Sendable (URL) -> Data?
)

var URLCachedSession: @Sendable (URLCache) -> CachedSession {
    { cache in
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .returnCacheDataElseLoad
        config.urlCache = cache
        let session = URLSession(configuration: config)
    
        return (
            download: { try await session.data(from: $0).0 },
            retrieve: { URLRequest(url: $0) ~> cache.cachedResponse(for:) ~> { $0?.data }}
        )
    }
}

infix operator ~>: AdditionPrecedence
