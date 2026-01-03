// © 2026  Cristian Felipe Patiño Rojas. Created on 3/1/26.

import SwiftUI

/*
 Sin embargo, todavía no podemos controlar el estado de loading, porque load() siempre se ejecuta y pisa isLoading.
 
 Podríamos delegar el estado hacia fuera:
 */

fileprivate struct MovieList: View {
    @State var isLoading: Bool = true
    @State var movies = [Movie]()
    @State var errorMessage: String?
    let load: () async throws -> [Movie]
    
    var body: some View {
        Self.list(
            isLoading: isLoading,
            movies: movies,
            errorMessage: errorMessage,
            didTapErrorButton: { errorMessage = nil }
        )
        .refreshable {
            do {
                errorMessage = nil
                movies = try await load()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
        .task(id: "initial init") {
            do {
                movies = try await load()
                isLoading = false
            } catch {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
    
    //  This could be splited into a separated dumb struct
    // if needed
    static func list(
        isLoading: Bool,
        movies: [Movie],
        errorMessage: String?,
        didTapErrorButton: @escaping () -> Void
    ) -> some View {
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
    MovieList.list(
        isLoading: true,
        movies: [],
        errorMessage: nil,
        didTapErrorButton: {}
    )
}

#Preview("Loaded") {
    MovieList.list(
        isLoading: false,
        movies: [mockMovie()],
        errorMessage: nil,
        didTapErrorButton: {}
    )
}

#Preview("Error on initial load") {
    MovieList.list(
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
    MovieList.list(
        isLoading: false,
        movies: [mockMovie()],
        errorMessage: anyError().localizedDescription,
        didTapErrorButton: {}
    )
}

/*
 And then we delegate loading & refresh to the state owner so
 we can simulate real case combinations in preview.
 */

#Preview("Initial Loading - Success") {
    MovieList(load: {
        try await Task.sleep(for: .seconds(3))
        return [mockMovie()]
    })
}

#Preview("Initial Loading - Failing on refresh") {
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

#Preview("Initial Loading - Adding items on refresh") {
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
