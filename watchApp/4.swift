// © 2026  Cristian Felipe Patiño Rojas. Created on 4/1/26.

import Foundation
import SwiftUI

extension MovieList {
    enum Phase {
        case loading
        case loaded([Movie])
        case error
    }
}

fileprivate struct MovieList: View {
    
    @State var phase = Phase.loading
    let load: () async throws -> [Movie]
    
    // Could be a different struct if needed
    @ViewBuilder
    static func list(phase: Phase) -> some View {
        switch phase {
        case .loading: ProgressView()
        case .loaded(let movies):
            List(movies, rowContent: MovieCell.init)
                .overlay {
                    if movies.isEmpty {
                        MoviesEmptyView()
                    }
                }
        case .error: ErrorView()
        }
    }
    
    var body: some View {
        Self.list(phase: phase)
            .task(load)
    }
    
    
    func load() async {
        do {
            let movies = try await load()
            phase = .loaded(movies)
        } catch {
            phase = .error
        }
    }
}

#Preview("Empty") {
    MovieList.list(phase: .loaded([]))
}
