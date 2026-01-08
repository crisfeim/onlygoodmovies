// © 2026  Cristian Felipe Patiño Rojas. Created on 6/1/26.

import SwiftUI

fileprivate struct MovieListController: View {
    @State var movies: [Movie]?
    @State var showError = false
    let loader: () async throws -> [Movie]
    var body: some View {
        MovieList(movies: movies, showError: $showError)
            .task(load)
            .refreshable(action: refresh)
    }
    
    func load() async {
        do {
            movies = try await loader()
        } catch {
            showError = true
        }
    }
    
    func refresh() async {
        showError = false
        await load()
    }
}


fileprivate struct MovieList: View {
    let movies: [Movie]?
    @Binding var showError: Bool
    var body: some View {
        List(movies ?? [], rowContent: Cell.init)
        .overlay {
            if movies == nil {
                ProgressView()
            }
        }
        .overlay {
            if let movies, movies.isEmpty {
                EmptyMoviesView()
            }
        }
        .toolbar {
            if let _ = movies, showError {
                ErrorButton {
                    showError = false
                }
            }
        }
    }
}

#Preview("Controller") {
    var shouldFail = false
    MovieListController {
        try await Task.sleep(for: .seconds(2))
        
        if shouldFail {
            print("should fail")
            shouldFail = false
            throw anyError()
        } else {
            print("should not fail")
            shouldFail = true
            return [mockMovie(), mockMovie()]
        }
    }
}

#Preview("Loading") {
    @Previewable @State var showError = false
    MovieList(movies: nil, showError: $showError)
}

#Preview("Loading - ShowError: true") {
    @Previewable @State var showError = true
    MovieList(movies: nil, showError: $showError)
}

#Preview("Loaded") {
    @Previewable @State var showError = false
    MovieList(movies: [mockMovie(), mockMovie(), mockMovie()], showError: $showError)
}

#Preview("Empty") {
    @Previewable @State var showError = false
    MovieList(movies: [], showError: $showError)
}

#Preview("Error") {
    @Previewable @State var showError = true
    MovieList(movies: [mockMovie(), mockMovie()], showError: $showError)
}

#Preview("Loaded + Error") {
    @Previewable @State var showError = true
    MovieList(movies: [mockMovie(), mockMovie(), mockMovie()], showError: $showError)
}


#Preview("Empty + Error") {
    @Previewable @State var showError = true
    MovieList(movies: [], showError: $showError)
}

