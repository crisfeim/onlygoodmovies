// © 2026  Cristian Felipe Patiño Rojas. Created on 13/1/26.
import Core
import Foundation

var RemoteMoviesLoader: (URL, HTTPClient) async throws -> [Movie] {
   { url, get in
       let (d, r) = try await get(url)
       return try MoviesMapper.map(d, r)
   }
}
