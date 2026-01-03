// © 2026  Cristian Felipe Patiño Rojas. Created on 3/1/26.

import SwiftUI

/*
 Sin embargo, todavía no podemos controlar el estado de loading, porque load() siempre se ejecuta y pisa isLoading.
 
 Podríamos delegar el estado hacia fuera:
 */

struct MovieList_3: View {
    let isLoading: Bool
    let movies: [Movie]
    let errorMessage: String?
    let didTapErrorButton: () -> Void
    var body: some View {
        List(movies) { movie in
            Text(movie.title)
           
        }
        .overlay {
            if movies.isEmpty && !isLoading {
                ContentUnavailableView("Movies", systemImage: "film.stack")
            }
        }
        .overlay {
            if isLoading {
                ProgressView().controlSize(.large)
            }
        }
        .toolbar {
            if let message = errorMessage {
                ToolbarItem(placement: .bottomBar) {
                    ErrorButton(label: message, action: didTapErrorButton)
                }
            }
        }
    }
}

#Preview("Loading") {
    MovieList_3(
        isLoading: true,
        movies: [],
        errorMessage: nil,
        didTapErrorButton: {}
    )
}

#Preview("Loaded") {
    MovieList_3(
        isLoading: false,
        movies: [mockMovie()],
        errorMessage: nil,
        didTapErrorButton: {}
    )
}

#Preview("Error on initial load") {
    MovieList_3(
        isLoading: false,
        movies: [],
        errorMessage: anyError().localizedDescription,
        didTapErrorButton: {}
    )
}

/*
 This allows us to test overlapping states:
 - Loaded but refreshing
 - Loaded & error after refresh, etc...
 */
#Preview("Error after reload") {
    MovieList_3(
        isLoading: false,
        movies: [mockMovie()],
        errorMessage: anyError().localizedDescription,
        didTapErrorButton: {}
    )
}

/*
 And then we delegate loading & refresh to whoever owns the state
 and will construct this view.
 */
//struct MovieList_3_Wrapper: View {
//    @State var isLoading = false
//    @State var movies = [Movie]()
//    @State var errorMessage: String?
//    let loader: () async throws -> [Movie]
//    var body: some View {
//        MovieList_3(
//            isLoading: isLoading,
//            movies: movies,
//            errorMessage: errorMessage,
//            didTapErrorButton: {errorMessage = nil})
//        .refreshable(action: load)
//        .task(load)
//    }
//    
//    func load() async {
//        do {
//            errorMessage = nil
//            isLoading = true
//            movies = try await loader()
//            isLoading = false
//        } catch {
//            errorMessage = error.localizedDescription
//            isLoading = false
//        }
//    }
//}
//
//#Preview("Wrapped view - Success") {
//    MovieList_3_Wrapper(loader: {
//        try await Task.sleep(for: .seconds(2))
//        return [mockMovie()]
//    })
//}
//
//#Preview("Wrapped view - failing on refresh") {
//    var isFirstLoad = true
//    MovieList_3_Wrapper(loader: {
//        try await Task.sleep(for: .seconds(1))
//        if isFirstLoad {
//            isFirstLoad = false
//            return [mockMovie()]
//        } else {
//            throw anyError()
//        }
//    })
//}


//
//
//extension MovieList_3 {
//    // Centralized state
//    // La firma de la vista no cambia al añadir estado.
//        // Mantiene call sites y previews funcionales (no se rompen)
//    struct Model {
//        var isLoading = true
//        var movies = [Movie]()
//        var errorMessage: String?
//    }
//}
//
//extension MovieList_3.Model {
//    static let loading = Self()
//    static func loaded(_ movies: [Movie]) -> Self {
//        Self(isLoading: false, movies: movies, errorMessage: nil)
//    }
//    static func error(_ message: String) -> Self {
//        Self(isLoading: false, movies: [], errorMessage: message)
//    }
//}
//

//
///* Combinaciones posibles que tienen sentido  */
//#Preview("Iteración 3 - Initial Loading") {
//    MovieList_3(model: .constant(.loading))
//}
//
//#Preview("Iteración 3 - Loaded Content") {
//    MovieList_3(model: .constant(.loaded([mockMovie()])))
//}
//
//#Preview("Iteración 3 - Empty List") {
//    MovieList_3(model: .constant(.loaded([])))
//}
//
//#Preview("Iteración 3 - Connection Error") {
//    MovieList_3(model: .constant(.error("Connection Error")))
//}
//
//#Preview("Iteración 3 - Refreshing Data") {
//    MovieList_3(model: .constant(.init(isLoading: true, movies: [mockMovie()], errorMessage: nil)))
//}
//
//#Preview("Iteración 3 - Refreshed Data Error") {
//    MovieList_3(model: .constant(.init(isLoading: false, movies: [mockMovie()], errorMessage: "Connection error")))
//}
//
///*Y lo usamos con un wrapper o composer que tenga la lógica de control de estado*/
//struct MovieList_3_wrapper: View {
//    @State var model = MovieList_3.Model.loading
//    let load: () async throws -> [Movie]
//    var body: some View {
//        MovieList_3(model: $model)
//            .refreshable {
//                do {
//                    model.isLoading = true
//                    model.movies = try await load()
//                    model.isLoading = false
//                } catch {
//                    model.errorMessage = error.localizedDescription
//                    model.isLoading = false
//                }
//            }
//            .task {
//                do {
//                    model = .loading
//                    model = .loaded(try await load())
//                } catch {
//                    model = .error(error.localizedDescription)
//                }
//                
//            }
//    }
//}
//
