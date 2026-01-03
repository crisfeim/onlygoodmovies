// © 2026  Cristian Felipe Patiño Rojas. Created on 3/1/26.

import SwiftUI


extension MovieList_5 {
    @Observable class Store {
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

struct MovieList_5: View {
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
    let store = MovieList_5.Store(load: {
        try await Task.sleep(for: .seconds(3))
        return [mockMovie()]
    })
    MovieList_5(store: store)
        .refreshable(action: store.refresh)
        .task(store.load)
}


#Preview("Failing on refresh") {
    var isFirstLoad = true
    let store = MovieList_5.Store(load: {
        try await Task.sleep(for: .seconds(1))
        if isFirstLoad {
            isFirstLoad = false
            return [mockMovie()]
        } else {
            throw anyError()
        }
    })
    
    MovieList_5(store: store)
        .refreshable(action: store.refresh)
        .task(store.load)
}

#Preview("Adding items on refresh") {
    var count = 0
    let store = MovieList_5.Store(load:{
        try await Task.sleep(for: .seconds(1))
        count += 1
        return (1...count).map {
            Movie(id: "\($0)", title: "Movie \($0)")
        }
    })
    
    MovieList_5(store: store)
        .refreshable(action: store.refresh)
        .task(store.load)
}
