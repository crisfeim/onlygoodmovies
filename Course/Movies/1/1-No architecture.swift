// © 2026  Cristian Felipe Patiño Rojas. Created on 6/1/26.

import SwiftUI
import Core

fileprivate struct MovieList: View {
    @State var phase = Phase.loading
    
    
    var body: some View {
        switch phase {
        case .loading: ProgressView().task(load)
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
    
    func load() async {
        do {
            let (d, _) = try await  URLSession.shared.data(from: Api.movies!)
            phase = .loaded(try JSONDecoder().decode([Movie].self, from: d))
        } catch {
            phase = .error
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


#Preview { MovieList() }
