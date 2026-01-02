// © 2026  Cristian Felipe Patiño Rojas. Created on 3/1/26.

import Foundation
import SwiftUI

/*
REQUIREMENTS
    Contract
         GET https://crisfe.im/apis/only-good-movies/v1
         statusCode: 200
         [{
             "id": uuid,
             "title": string,
             "releaseYear": date
         }]
    UseCases
         Sad path -> N/A
         Happy path -> Displays movie list
         App must display loading view during loading
    Design
         SwiftUI List with Text(movie.title) for each movie.
 */


struct MovieList_1: View {
    @State private var movies: [Movie]?

    var body: some View {
        if let movies = movies {
            List(movies) { movie in
                Text(movie.title)
            }
        } else {
            ProgressView()
                .task {
                    let (data, _) = try! await URLSession.shared.data(from: Api.movies!)
                    movies = try! JSONDecoder().decode([Movie].self, from: data)
                }
        }
    }
}


#Preview {
    MovieList_1()
}

