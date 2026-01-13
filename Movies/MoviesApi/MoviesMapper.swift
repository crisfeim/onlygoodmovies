// © 2026  Cristian Felipe Patiño Rojas. Created on 13/1/26.

import SwiftUI

enum MoviesMapper {
    struct InvalidData: Error {}
    static let OK = 200
    
    struct DTO: Identifiable, Decodable, Equatable, Sendable {
        let id: String
        let title: String
        let poster_url: String
        let release_year: Int
        
        init(id: String, title: String, poster_url: String, release_year: Int) {
            self.id = id
            self.title = title
            self.poster_url = poster_url
            self.release_year = release_year
        }
    }

    static var map: (Data, HTTPURLResponse) throws -> [Movie] {
        { d, r in
            guard r.statusCode == OK else { throw InvalidData() }
            let movies = try JSONDecoder().decode([DTO].self, from: d)
            return movies.map {
                Movie(id: $0.id, title: $0.title, posterURL: $0.poster_url, releaseYear: $0.release_year)
            }
        }
    }
}
