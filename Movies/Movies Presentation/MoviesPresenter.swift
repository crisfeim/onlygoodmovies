// © 2026  Cristian Felipe Patiño Rojas. Created on 13/1/26.

import SwiftUI

@MainActor
public struct MoviesPresenter {
   @Binding var state: MoviesState
   @Binding var config: MoviesConfig
   private let loader: MoviesLoader
    
    public init(_ state: Binding<MoviesState>, _ config: Binding<MoviesConfig>, loader: @escaping MoviesLoader) {
        self._state = state
        self._config = config
        self.loader = loader
    }
   
   public func firstLoad() async {
       didStartLoading()
       await load(onError: removeMoviePlaceholders)
       didStopLoading()
   }

   public func refresh() async {
       guard !state.showLoading else { return }
       state.showError = false
       await load()
   }
    
    private func load(onError: (() -> Void)? = nil) async {
        do {
            for try await movie in loader() {
                if state.movies.contains(.placeholder) {
                    state.movies.removeFirst()
                }
                if config == .loading { config = .idle }
                state.movies.append(movie)
            }
            state.showEmpty = state.movies.isEmpty
        } catch {
            state.showError = true
            onError?()
        }
    }
    
    private func didStartLoading() {
        state.movies = [.placeholder]
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

public extension Movie {
    static var placeholder: Self {
        Movie(id: "placeholder_1", title: "Some Movie Long Title", posterURL: "", releaseYear: 2000)
    }
}
