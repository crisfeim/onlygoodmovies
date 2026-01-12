// © 2026  Cristian Felipe Patiño Rojas. Created on 8/1/26.

import Core
import SwiftUI

fileprivate struct MovieList: View {
    @State var phase = Phase.loading
    let loader: () async throws -> [Movie]
    
    var body: some View {
        Self.body(phase)
            .task {
                do {
                    phase = .loaded(try await loader())
                } catch {
                    phase = .error
                }
            }
    }
    
    @ViewBuilder
    static func body(_ phase: Phase) -> some View {
        switch phase {
        case .loading: ProgressView()
        case .loaded(let movies):
            List(movies, rowContent: MovieCell.init)
                .overlay {
                    if movies.isEmpty {
                        EmptyMoviesView()
                    }
                }
        case .error: ErrorView()
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
    MovieList.body(.loading)
}


#Preview("Loaded") {
    MovieList.body(.loaded([mockMovie()]))
}

#Preview("Empty") {
    MovieList.body(.loaded([]))
}

#Preview("Error") {
    MovieList.body(.error)
}

