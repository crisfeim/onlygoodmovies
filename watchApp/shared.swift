// © 2026  Cristian Felipe Patiño Rojas. Created on 4/1/26.

struct Movie: Identifiable, Decodable {
    let id: String
    let title: String
    let poster_url: String
    let release_year: Int
}
