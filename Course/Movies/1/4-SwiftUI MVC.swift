// © 2026  Cristian Felipe Patiño Rojas. Created on 6/1/26.

import SwiftUI

fileprivate struct MovieListController: View {
    @State var phase = MovieList.Phase.loading
    let loader: () async throws -> [Movie]
    
    var body: some View {
        MovieList(phase: phase)
            .task {
                do {
                    phase = .loaded(try await loader())
                } catch {
                    phase = .error
                }
            }
    }
}


fileprivate struct MovieList: View {
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

extension MovieList {
    enum Phase {
        case loading
        case loaded([Movie])
        case error
    }
}


#Preview {
    MovieListController {
        let (d, _) = try await  URLSession.shared.data(from: Api.movies!)
        return try JSONDecoder().decode([Movie].self, from: d)
    }
}
