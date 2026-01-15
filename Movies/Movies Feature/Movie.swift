// © 2026  Cristian Felipe Patiño Rojas. Created on 13/1/26.

public struct Movie: Identifiable, Equatable, Sendable {
    public let id: String
    public let title: String
    public let posterURL: String
    public let releaseYear: Int
    
    public init(id: String, title: String, posterURL: String, releaseYear: Int) {
        self.id = id
        self.title = title
        self.posterURL = posterURL
        self.releaseYear = releaseYear
    }
}
