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
    public var movies: [Movie] {
        get { data ?? [] }
        set { data = newValue }
    }
    
    private var data: [Movie]?
    public var hasError = false
    
    public init(movies: [Movie]? = nil, hasError: Bool = false) {
        self.data = movies
        self.hasError = hasError
    }
    
    public var isLoading: Bool {
        data == nil && !hasError
    }
    
    public var showEmpty: Bool {
        guard let data = data else { return false }
        return data.isEmpty
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
       do {
           state.movies = try await loader()
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
