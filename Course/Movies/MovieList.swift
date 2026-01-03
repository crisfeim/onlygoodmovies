// © 2026  Cristian Felipe Patiño Rojas. Created on 3/1/26.

import SwiftUI

struct MovieList: View {
    @State var isLoading = true
    @State var movies: [Movie] = []
    @State var errorMessage: String?
    var body: some View {
        List(movies) { movie in
            Text(movie.title)
           
        }
        .overlay {
            if movies.isEmpty {
                ContentUnavailableView("Movies", systemImage: "film.stack")
            }
        }
        .overlay {
            if isLoading {
                ProgressView().controlSize(.large)
            }
        }
        .refreshable(action: refresh)
        .task(load)
        .toolbar {
            if let message = errorMessage {
                ErrorButton(label: message) {
                    errorMessage = nil
                }
            }
        }
    }
    
    func refresh() async {
        do {
            let (d, _) = try await  URLSession.shared.data(from: Api.movies!)
            movies = try JSONDecoder().decode([Movie].self, from: d)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func load() async {
        guard movies.isEmpty else { return }
        do {
            let (d, _) = try await  URLSession.shared.data(from: Api.movies!)
            movies = try JSONDecoder().decode([Movie].self, from: d)
            movies = []
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
}



#Preview("List") {
    MovieList()
}
