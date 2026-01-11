// © 2026  Cristian Felipe Patiño Rojas. Created on 11/1/26.

import Foundation
struct Movie: Equatable {
    let id: UUID
    let name: String
}

import SwiftUI
fileprivate struct Compose<Model, Content: View>: View {
    @State var state: Model
    let content: (Binding<Model>) -> Content
    var body: some View { content($state) }
}


fileprivate struct MovieList: View {
    struct Model {
        var movies: [Movie]?
        var showError = false
    }
    
    @Binding var state: Model
    var body: some View {
        
    }
}

fileprivate let mounted = Compose(state: MovieList.Model(), content: MovieList.init)


fileprivate struct MovieListController: View {
    @Binding var movies: [Movie]?
    @Binding var showError: Bool
    let loader: () async throws -> [Movie]
    var body: some View {
      Text("hello world")
    }
    
    func load() async {
        do { movies = try await loader()
        } catch { showError = true }
    }
    
    func refresh() async {
        showError = false
        await load()
    }
}

import XCTest

class MovieListTests: XCTestCase {
    func test_loadShowsErrorOnLoaderFailure() async {
        let movies     : Binding<[Movie]?> = makeBinding(nil)
        let showError  : Binding<Bool>     = makeBinding(false)
        
        let sut = MovieListController(movies: movies, showError: showError) {
            throw NSError(domain: "any-error", code: 0)
        }
        
        await sut.load()
        
        XCTAssertNil(movies.wrappedValue)
        XCTAssertTrue(showError.wrappedValue)
    }
    
    func test_loadShowsMoviesOnLoaderSuccess() async {
        let movies     : Binding<[Movie]?> = makeBinding(nil)
        let showError  : Binding<Bool>     = makeBinding(false)
        
        let stubbedMovie = Movie(id: UUID(), name: "any-movie")
        let sut = MovieListController(movies: movies, showError: showError) {
            [stubbedMovie]
        }
        
        await sut.load()
        
        XCTAssertEqual(movies.wrappedValue, [stubbedMovie])
        XCTAssertFalse(showError.wrappedValue)
    }
    
    func test_refreshShowsErrorOnLoaderFailure() async {
        
        let stubbedMovie = Movie(id: UUID(), name: "any-movie")
        let movies     : Binding<[Movie]?> = makeBinding([stubbedMovie])
        let showError  : Binding<Bool>     = makeBinding(false)
        
        
        let sut = MovieListController(movies: movies, showError: showError) {
            throw NSError(domain: "any-error", code: 0)
        }
        
        await sut.refresh()
        
        XCTAssertEqual(movies.wrappedValue, [stubbedMovie])
        XCTAssertTrue(showError.wrappedValue)
    }
}


fileprivate func makeBinding<T>(_ value: T) -> Binding<T> {
   var value = value
   return Binding(get: { value }, set: { value = $0 })
}
