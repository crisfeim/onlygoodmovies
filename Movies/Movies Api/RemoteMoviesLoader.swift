// © 2026  Cristian Felipe Patiño Rojas. Created on 13/1/26.
import Foundation

public var RemoteMoviesLoader: (URL, @escaping HTTPClient) -> MoviesLoader {
   return { url, get in
       {
           let (d, r) = try await get(url)
           return try MoviesMapper.map(d, r)
       }
   }
}
