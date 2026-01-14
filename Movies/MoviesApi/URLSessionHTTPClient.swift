// © 2026  Cristian Felipe Patiño Rojas. Created on 13/1/26.
import Foundation

public func URLSessionHTTPClient(_ session: URLSession) -> HTTPClient {
    struct UnexpectedValuesRepresentation: Error {}
    return { url in
        let (d, r) = try await session.data(from: url)
        if let r = r as? HTTPURLResponse { return (d, r) }
        throw UnexpectedValuesRepresentation()
    }
}
