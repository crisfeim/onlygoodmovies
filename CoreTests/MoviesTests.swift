// © 2026  Cristian Felipe Patiño Rojas. Created on 11/1/26.

// © 2026  Cristian Felipe Patiño Rojas. Created on 3/1/26.


//
//fileprivate typealias HTTPGet = @Sendable (URL) async throws -> (Data, URLResponse) // @todo: should return a HTTPURLResponse instead
//
//fileprivate var RemoteLoader: (HTTPGet) async throws -> [Movie] {
//    { get in
//        let (d, r) = try await get(URL(string: "https://crisfe.im/apis/only-good-movies/v1")!)
//        return try MoviesMapper(d, r)
//    }
//}
//
//fileprivate var MoviesMapper: (Data, URLResponse) throws -> [Movie] { // @todo: should take a HTTPURLResponse instead
//    { d, _ in try JSONDecoder().decode([Movie].self, from: d) }
//}
//
//fileprivate var remoteLoader: MoviesLoader {
//    { try await RemoteLoader(URLSession.shared.data(from:)) }
//}
// 
//@main
//struct CourseApp: App {
//    @State private var state = MoviesState()
//    var body: some Scene {
//        WindowGroup {
//            Inject(.init()) {
//                MoviesComposition(state: $0, moviesLoader: remoteLoader~>withRetry|2)
//            }
//        }
//    }
//}
//
//import SwiftUI
//fileprivate struct Inject<Model, Content: View>: View {
//    @State var state: Model
//    let content: (Binding<Model>) -> Content
//    
//    init(_ state: Model, content: @escaping (Binding<Model>) -> Content) {
//        self.state = state
//        self.content = content
//    }
//    
//    var body: some View { content($state) }
//}
//
//
//infix operator ~>: AdditionPrecedence
//func ~> <T, U>(lhs: T, rhs: (T) -> U) -> U { rhs(lhs) }
//
//
//infix operator |: MultiplicationPrecedence
//func | <T, U, V>(lhs: @escaping (T, U) -> V, rhs: U) -> (T) -> V {
//    return { T in lhs(T, rhs) }
//}
//
//
//fileprivate typealias MoviesLoader = () async throws -> [Movie]

//fileprivate struct MoviesState {
//    var movies: [Movie]?
//    var showError = false
//    
//    var showLoading: Bool { movies == nil }
//    var showEmpty  : Bool { movies != nil && movies!.isEmpty }
//    
//}
//
//fileprivate struct MoviesComposition: View {
//    
//    @Binding var state: MoviesState
//    
//    let moviesLoader : MoviesLoader
//    
//    var body: some View {
//        MovieList(state: $state)
//        .task(load)
//        .refreshable(action: load)
//    }
//    
//    func load() async {
//        do { state.movies = try await moviesLoader() }
//        catch { state.showError = true }
//    }
//}

//fileprivate struct MovieLisLogic: View {
//    @Binding var state: MoviesState
//    var body: some View {
//        List(state.movies ?? []) {
//            Text($0.title)
//        }
//            .overlay { if state.showLoading { ProgressView() } }
//            .overlay { if state.showEmpty { Text("Empty") } }
//            .toolbar { if state.showError { Text("Error") { state.showError = false } }
//        }
//    }
//}

//extension MovieListLogic: View {
//    
//}

//fileprivate func withRetry<T>(_ load: @escaping () async throws -> T, attempts: Int = 3) -> () async throws -> T {
//    {
//        var attempts = attempts
//        while true {
//            do { return try await load() }
//            catch { attempts += 1; if attempts >= 3 { throw error } }
//        }
//    }
//}

import SwiftUI
import XCTest



class MoviesTests: XCTestCase {
     struct MoviesState {
         var movies: [Movie]?
         var hasError = false
         var isLoading: Bool { movies == nil }
    }
    
    struct MoviesLogic {
        @Binding var state: MoviesState
    }
    
    func test_assertInitialState() {
        let state = MoviesState()
        XCTAssertNil(state.movies)
        XCTAssertTrue(state.isLoading)
        XCTAssertFalse(state.hasError)
    }
    
    func test_initDoesntMutatesState() {
        var state = MoviesState()
        let binding = Binding(get: { state }, set: { state = $0 })
        let _ = MoviesLogic(state: binding)
        XCTAssertNil(state.movies)
        XCTAssertTrue(state.isLoading)
        XCTAssertFalse(state.hasError)
    }
}
