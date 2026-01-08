// © 2026  Cristian Felipe Patiño Rojas. Created on 8/1/26.

import SwiftUI

fileprivate struct MovieList: View {
    @State var phase = Phase.loading
    let loader: () async throws -> [Movie]
    
    var body: some View {
       Content(phase: phase)
            .task {
                do {
                    phase = .loaded(try await loader())
                } catch {
                    phase = .error
                }
            }
    }
    
    struct Content: View {
        let phase: Phase
        var body: some View {
            switch phase {
            case .loading: ProgressView()
            case .loaded(let movies):
                List(movies, rowContent: Cell.init)
                    .overlay {
                        if movies.isEmpty {
                            EmptyMoviesView()
                        }
                    }
            case .error: ErrorView()
            }
        }
    }
}

fileprivate extension MovieList {
    enum Phase {
        case loading
        case loaded([Movie])
        case error
    }
}


#Preview("Loading") {
    MovieList.Content(phase: .loading)
}


#Preview("Loaded") {
    MovieList.Content(phase: .loaded([mockMovie()]))
}

#Preview("Empty") {
    MovieList.Content(phase: .loaded([]))
}

#Preview("Error") {
    MovieList.Content(phase: .error)
}

