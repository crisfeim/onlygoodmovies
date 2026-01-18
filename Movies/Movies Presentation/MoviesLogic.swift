// © 2026  Cristian Felipe Patiño Rojas. Created on 13/1/26.

import SwiftUI

@MainActor
public struct MoviesLogic {
   @Binding var state: MoviesState
   @Binding var config: MoviesConfig
   private let loader: MoviesLoader
    
    public init(_ state: Binding<MoviesState>, _ config: Binding<MoviesConfig>, loader: @escaping MoviesLoader) {
        self._state = state
        self._config = config
        self.loader = loader
    }
   
   public func load() async {
       defer { state.showLoading = false }
       state.movies = .placeholders
       config = .loading
       do {
           let movies = try await loader()
           setMovies(movies)
           state.showEmpty = state.movies.isEmpty
           config = .idle
       } catch {
           setMovies([])
           config = .idle
           state.showError = true
       }
   }

   public func refresh() async {
       guard !state.showLoading else { return }
       state.showError = false
       await load()
   }
    
    private func setMovies(_ movies: [Movie]) {
        withAnimation { state.movies = movies }
    }
}

public extension [Movie] {
    static var placeholders: Self {
        (0...10).map { index in
            Movie(id: "placeholder_" + String(index), title: "Some Movie Long Title", posterURL: "", releaseYear: 2000)
        }
    }
}
