// © 2026  Cristian Felipe Patiño Rojas. Created on 13/1/26.

import SwiftUI
import Core

enum MoviesMapper {
    struct InvalidData: Error {}
    static let OK = 200
    static var map: (Data, HTTPURLResponse) throws -> [Movie] {
        { d, r in
            guard r.statusCode == OK else { throw InvalidData() }
            return try JSONDecoder().decode([Movie].self, from: d)
        }
    }
}
