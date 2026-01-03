// © 2026  Cristian Felipe Patiño Rojas. Created on 3/1/26.
import SwiftUI
/*
 
Este enfoque funciona.
Satisface las necesidades del sistema.

Sin embargo hay algunas fricciones importantes a considerar.
El primero y más importante es que nuestras previews hacen peticiones reales, (@todo: debería hablar del acoplamiento de la vista a un dto primeero, porque el tema de la preview se fue de madres y quedó algo largo y con muchos cambios en la última iteración, no estoy seguro de q cronologicamente tenga sentido hablar entonces del desacoplamiento al dto)
lo que hace díficil probar los diferentes estados que puede tener la pantalla
 
Podemos mejorar esto inyectando el fetch.
*/
struct MovieList_2: View {
    @State var isLoading = true
    @State var movies: [Movie] = []
    @State var errorMessage: String?
    let loader: () async throws -> [Movie]
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
                ToolbarItem(placement: .bottomBar) {
                    ErrorButton(label: message) {
                        errorMessage = nil
                    }
                }
            }
        }
    }
    
    func load() async {
        do {
            movies = try await loader()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func initLoad() async {
        await load()
        isLoading = false
    }
}

/*
 Ahora podemos crear previews para el estado de error y success sin
 hacer peticiones reales:
 */
#Preview("Iteración 2 - Error") {
    MovieList_2(loader: {throw NSError(domain: "any-error", code: 0)})
}

#Preview("Iteración 2 - Loaded") {
    var callCount = 0
    MovieList_2(loader: {
        callCount += 1
        return Array(0...callCount).map {
            Movie(id: $0.description, title: "Movie \($0+1)")
        }
    })
}

/*
 Sin embargo, no podemos hacer una preview de estados overlapping:
 Empty list + loading
 Loaded list + loading
 Loaded list + error
 
 Etc...
 */
