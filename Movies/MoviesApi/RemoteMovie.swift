// © 2026  Cristian Felipe Patiño Rojas. Created on 13/1/26.


import SwiftUI

public struct RemoteMovie: Identifiable, Decodable, Equatable, Sendable {
    public let id: String
    public let title: String
    public let poster_url: String
    public let release_year: Int
    
    public init(id: String, title: String, poster_url: String, release_year: Int) {
        self.id = id
        self.title = title
        self.poster_url = poster_url
        self.release_year = release_year
    }
}
