// © 2026  Cristian Felipe Patiño Rojas. Created on 6/1/26.

import SwiftUI

fileprivate struct MovieList: View {
    @State var phase = Phase.loading
    let loader: () async throws -> [Movie]
    
    var body: some View {
        switch phase {
        case .loading: ProgressView().task(load)
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
    
    func load() async {
        do {
            phase = .loaded(try await loader())
            
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


#Preview("Loaded") { MovieList { [mockMovie()] } }
#Preview("Empty")  { MovieList {[]} }
#Preview("Error")  { MovieList { throw anyError() } }
