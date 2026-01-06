// © 2026  Cristian Felipe Patiño Rojas. Created on 3/1/26.

import SwiftUI

// In the previous example, the state control logic was within the view.
// making difficult to assert state transition through unit testing.
// previews can be a good way of manually testing this behaviour, howver I prefer to not rely on them
// and unit test as much as I can.
// so, one way of allowing testing is moving our store to a reference type and placing inside the state control logic.
extension MovieList {
    @Observable @MainActor class Store {
        private(set) var firstLoading = true
        private(set) var movies = [Movie]()
        private(set) var errorMessage: String?
        
        let load: () async throws -> [Movie]
        
        init(load: @escaping () async throws -> [Movie]) {
            self.load = load
        }
        
        func clearMessage() {
            errorMessage = nil
        }
        
        func refresh() async {
            do {
                errorMessage = nil
                movies = try await load()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
        
        func load() async {
            guard firstLoading else { return }
            defer { firstLoading = false }
            do {
                movies = try await load()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}

fileprivate struct MovieList: View {
    // store is injected from outside so whoever constructs the view is also responsible for managing state
   // this way we preserve the ortogonal state previewing (otherwise applying task & refeshable here would destroy the init loading state making it not previewable
  // and we  simplify the view respnsabilities (not constructing its dependencies & not managing state)
    @State var store: Store
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


#Preview("Success") {
    let store = MovieList.Store(load: {
        try await Task.sleep(for: .seconds(3))
        return [anyMovie()]
    })
    MovieList(store: store)
        .refreshable(action: store.refresh)
        .task(store.load)
}


#Preview("Failing on refresh") {
    var isFirstLoad = true
    let store = MovieList.Store(load: {
        try await Task.sleep(for: .seconds(1))
        if isFirstLoad {
            isFirstLoad = false
            return [anyMovie()]
        } else {
            throw anyError()
        }
    })
    
    MovieList(store: store)
        .refreshable(action: store.refresh)
        .task(store.load)
}

#Preview("Adding items on refresh") {
    var count = 0
    let store = MovieList.Store(load:{
        try await Task.sleep(for: .seconds(1))
        count += 1
        return (1...count).map {
            anyMovie(id: "\($0)", title: "Movie \($0)")
        }
    })
    
    MovieList(store: store)
        .refreshable(action: store.refresh)
        .task(store.load)
}

/*
 Ahora que la responsabilidad de está en manos del composer, podemos
 tener un composite tal que:
 */
fileprivate enum MovieListComposer {
    typealias Loader = () async throws -> [Movie]
    @MainActor
    static func compose(loader: @escaping Loader) -> some View {
        let store = MovieList.Store(load: loader)
        let view = MovieList(store: store)
        return view
            .refreshable(action: store.refresh)
            .task(store.load)
    }
}


/*
 Podemos componer la feature:
 */

fileprivate struct MoviesApp: View {
    var body: some View {
        TabView {
            
            Tab("Movies", systemImage: "film.stack") {
                MovieListComposer.compose(loader: loadFromRemote)
            }
            
            Tab("Favorites", systemImage: "star") {
                MovieListComposer.compose(loader: loadFromSwiftData)
            }
        }
    }
    
    func loadFromSwiftData() async throws -> [Movie] {
        [/* ... implementatiion */ ]
    }
    
    func loadFromRemote() async throws -> [Movie] {
        [anyMovie(), anyMovie(), anyMovie()]
    }
}


#Preview("Composition") {
    MoviesApp()
}

/*
 Qué se gana:
     •    Estado testeable
     •    Vista completamente pasiva
     •    Async fuera del árbol de vistas
     •    Composición flexible

 Aquí aparece algo importante sin nombrarlo:
     •    El store es un objeto de dominio de UI
     •    El composer decide el wiring
     •    La vista no sabe nada del mundo
 
 
 1. La potencia del Composite Pattern

 En tu última iteración (MovieListComposer), has dado con la clave de la Arquitectura Clean: el desacoplamiento de la creación. Al separar la construcción (compose) de la definición de la vista, permites que MovieList sea una "Pure View".

 Punto clave para tu artículo: Resalta que MovieList ya no sabe de dónde vienen las películas ni cómo se cargan. Solo sabe pintar lo que el Store le dice. Esto es lo que permite que en tu demo interactiva el usuario pueda "ensamblar" diferentes loaders.
 */
