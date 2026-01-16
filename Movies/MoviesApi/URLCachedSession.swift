// © 2026  Cristian Felipe Patiño Rojas. Created on 16/1/26.
import Foundation

public typealias CachedSession = (
    download: @Sendable (URL) async throws -> Data,
    retrieve: @Sendable (URL) -> Data?
)

public var URLCachedSession: @Sendable (URLCache) -> CachedSession {
    { cache in
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .returnCacheDataElseLoad
        config.urlCache = cache
        let session = URLSession(configuration: config)
    
        return (
            download: { try await session.data(from: $0).0 },
            retrieve: { cache.cachedResponse(for: URLRequest(url: $0))?.data }
        )
    }
}
