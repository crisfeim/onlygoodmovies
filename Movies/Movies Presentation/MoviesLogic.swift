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
   
   public func firstLoad() async {
       defer { didStopLoading() }
       didStartLoading()
       await load(onError: removeMoviePlaceholders)
   }

   public func refresh() async {
       guard !state.showLoading else { return }
       state.showError = false
       await load()
   }
    
    private func load(onError: (() -> Void)? = nil) async {
        do {
            setMovies(try await loader())
            state.showEmpty = state.movies.isEmpty
        } catch {
            state.showError = true
            onError?()
        }
    }
    
    private func didStartLoading() {
        state.movies = .placeholders
        state.showLoading = true
        config = .loading
    }
    
    private func didStopLoading() {
        state.showLoading = false
        config = .idle
    }
    
    private func setMovies(_ movies: [Movie]) {
        withAnimation { state.movies = movies }
    }
    
    private func removeMoviePlaceholders() {
        setMovies([])
    }
}

public extension [Movie] {
    static var placeholders: Self {
        (0...10).map { index in
            Movie(id: "placeholder_" + String(index), title: "Some Movie Long Title", posterURL: "", releaseYear: 2000)
        }
    }
}
