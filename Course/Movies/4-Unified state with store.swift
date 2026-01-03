import SwiftUI

/*
Since this solution involves a call site (our wrapper)
that could break on state additions (we would need to manually
add state to both, the view & the function wrapper) we could
protect our solution from breaking changes by by grouping
our state into a unified store.
 */
extension MovieList {
    struct Store {
        
        // Centralized state
        // La firma de la vista no cambia al añadir estado.
        // Mantiene call sites y previews funcionales (no se rompen)
        var firstLoading = true
        var movies = [Movie]()
        var errorMessage: String?
        
        mutating func clearMessage() {
            errorMessage = nil
        }
    }
}

fileprivate struct MovieList: View {
    @State var store = Store()
    let load: () async throws -> [Movie]
    
    var body: some View {
        ListView(store: $store)
        .refreshable {
            do {
                store.errorMessage = nil
                store.movies = try await load()
            } catch {
                store.errorMessage = error.localizedDescription
            }
        }
        .task() {
            guard store.firstLoading else { return }
            defer { store.firstLoading = false }
            do {
                store.movies = try await load()
            } catch {
                store.errorMessage = error.localizedDescription
            }
        }
    }
    
    struct ListView: View {
        @Binding var store: Store
        var body: some View {
            List(store.movies) { movie in
                Text(movie.title)
            }
            .overlay {
                if store.movies.isEmpty && !store.firstLoading {
                    ContentUnavailableView("Movies", systemImage: "film.stack")
                }
            }
            .overlay {
                if store.firstLoading {
                    ProgressView().controlSize(.large)
                }
            }
            .toolbar {
                if let message = store.errorMessage {
                    ToolbarItem(placement: .bottomBar) {
                        ErrorButton(label: message, action: { store.clearMessage() })
                    }
                }
            }
        }
    }
}



#Preview("Success") {
    MovieList(load: {
        try await Task.sleep(for: .seconds(3))
        return [mockMovie()]
    })
}

#Preview("Failing on refresh") {
    var isFirstLoad = true
    MovieList(load: {
        try await Task.sleep(for: .seconds(1))
        if isFirstLoad {
            isFirstLoad = false
            return [mockMovie()]
        } else {
            throw anyError()
        }
    })
}

#Preview("Adding items on refresh") {
    var count = 1
    MovieList(load: {
        try await Task.sleep(for: .seconds(1))
        let items = Array(1...count).map {
            Movie(id: $0.description, title: "Movie \($0)")
        }
        count += 1
        return items
    })
}

/*
 Motivo concreto:
     •    La firma de la vista empieza a ser frágil
     •    Cada nuevo flag obliga a tocar demasiados sitios

 Qué cambia:
     •    Estado agrupado
     •    La vista depende de una sola cosa
     •    Añadir estado no rompe call sites

 Importante:
     •    Esto no es MVVM
     •    No hay async en la vista
     •    Sigue siendo SwiftUI puro
 */
