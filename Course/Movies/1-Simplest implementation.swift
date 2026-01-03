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
         Sad path
            Network Error: Display error message
            Decoding Error: Display error message
         Happy path: Displays movie list
    Design
        See design
 */


/*
 La implementación más sencilla posible de nuestra app
*/
struct MovieList_1: View {
    @State var isLoading = true
    @State var movies: [Movie] = []
    @State var errorMessage: String?
    var body: some View {
        List(movies) { movie in
            Text(movie.title)
           
        }
        .overlay {
            if movies.isEmpty {
                ContentUnavailableView("Movies", systemImage: "film.stack")
            }
        }
        .overlay {
            if isLoading {
                ProgressView().controlSize(.large)
            }
        }
        .refreshable(action: load)
        .task(id: "init load", initLoad)
        .toolbar {
            if let message = errorMessage {
                ErrorButton(label: message) {
                    errorMessage = nil
                }
            }
        }
    }
    
    func load() async {
        do {
            let (d, _) = try await  URLSession.shared.data(from: Api.movies!)
            movies = try JSONDecoder().decode([Movie].self, from: d)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func initLoad() async {
        await load()
        isLoading = false
    }
}

#Preview("Iteración 1") {
    MovieList_1()
}

