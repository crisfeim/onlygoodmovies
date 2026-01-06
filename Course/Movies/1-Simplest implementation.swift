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
fileprivate struct MovieList: View {
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
        .task(initLoad)
        .toolbar {
            if let message = errorMessage {
                ErrorButton(label: message) {
                    errorMessage = nil
                }
            }
        }
    }
    
    @Sendable func load() async {
        do {
            let (d, _) = try await  URLSession.shared.data(from: Api.movies!)
            movies = try JSONDecoder().decode([Movie].self, from: d)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    @Sendable func initLoad() async {
        await load()
        isLoading = false
    }
}

#Preview("Iteración 1") {
    MovieList()
}

/*
 Conclusión
 •    La vista es responsable de:
 •    ciclo de vida
 •    estado
 •    networking
 •    errores
 •    .task + .refreshable pisan el mismo estado
 •    El significado de isLoading es frágil
 •    Las previews son decorativas, no útiles
 •    Funciona, pero no se puede observar ni controlar el comportamiento.
 */
