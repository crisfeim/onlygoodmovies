// © 2026  Cristian Felipe Patiño Rojas. Created on 13/1/26.

public struct Movie: Identifiable, Equatable {
    public let id: String
    let title: String
    let posterURL: String
    let releaseYear: Int
    
    public init(id: String, title: String, posterURL: String, releaseYear: Int) {
        self.id = id
        self.title = title
        self.posterURL = posterURL
        self.releaseYear = releaseYear
    }
}
