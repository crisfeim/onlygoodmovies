// © 2026  Cristian Felipe Patiño Rojas. Created on 13/1/26.
import Core
import Foundation

var RemoteLoader: (HTTPClient) async throws -> [Movie] {
   { get in
       let (d, r) = try await get(URL(string: "https://crisfe.im/apis/only-good-movies/v1")!)
       return try MoviesMapper.map(d, r)
   }
}
