// © 2026  Cristian Felipe Patiño Rojas. Created on 13/1/26.
import Foundation

var urlSessionHTTPClient: HTTPClient {
    struct UnexpectedValuesRepresentation: Error {}
    return { url in
        let (d, r) = try await URLSession.shared.data(from: url)
        if let r = r as? HTTPURLResponse { return (d, r) }
        throw UnexpectedValuesRepresentation()
    }
}
