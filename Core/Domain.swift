// © 2026  Cristian Felipe Patiño Rojas. Created on 11/1/26.

import SwiftUI

public struct Movie: Identifiable, Decodable, Equatable, Sendable {
    public let id: String
    public let title: String
    public let poster_url: String
    public let release_year: Int
    
    public init(id: String, title: String, poster_url: String, release_year: Int) {
        self.id = id
        self.title = title
        self.poster_url = poster_url
        self.release_year = release_year
    }
}

public struct MoviesState {
    public var movies: [Movie]
    public var hasError: Bool
    public var isLoading: Bool
    public var showEmpty: Bool
    
    public init(movies: [Movie] = [], isLoading: Bool = true, hasError: Bool = false, showEmpty: Bool = false) {
        self.movies = movies
        self.isLoading = isLoading
        self.hasError = hasError
        self.showEmpty = showEmpty
    }
}

public struct MoviesLogic {
   @Binding var state: MoviesState
   private let loader: MoviesLoader
    
    public init(state: Binding<MoviesState>, loader: @escaping MoviesLoader) {
        self._state = state
        self.loader = loader
    }
   
   public func load() async {
       defer { state.isLoading = false }
       do {
           state.movies = try await loader()
           state.showEmpty = state.movies.isEmpty
       } catch {
           state.hasError = true
       }
   }

   public func refresh() async {
       guard !state.isLoading else { return }
       state.hasError = false
       await load()
   }
}

public typealias MoviesLoader = () async throws -> [Movie]
