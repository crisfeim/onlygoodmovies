// © 2026  Cristian Felipe Patiño Rojas. Created on 13/1/26.


import SwiftUI
import Movies

public struct MoviesLogic {
   @Binding var state: MoviesState
   private let loader: MoviesLoader
    
    public init(state: Binding<MoviesState>, loader: @escaping MoviesLoader) {
        self._state = state
        self.loader = loader
    }
   
   public func load() async {
       defer { state.showLoading = false }
       do {
           state.movies = try await loader()
           state.showEmpty = state.movies.isEmpty
       } catch {
           state.showError = true
       }
   }

   public func refresh() async {
       guard !state.showLoading else { return }
       state.showError = false
       await load()
   }
}
