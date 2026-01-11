// © 2026  Cristian Felipe Patiño Rojas. Created on 3/1/26.

import SwiftUI


fileprivate typealias HTTPGet = @Sendable (URL) async throws -> (Data, URLResponse) // @todo: should return a HTTPURLResponse instead

fileprivate var RemoteLoader: (HTTPGet) async throws -> [Core.Movie] {
    { get in
        let (d, r) = try await get(URL(string: "https://crisfe.im/apis/only-good-movies/v1")!)
        return try MoviesMapper(d, r)
    }
}

fileprivate var MoviesMapper: (Data, URLResponse) throws -> [Core.Movie] { // @todo: should take a HTTPURLResponse instead
    { d, _ in try JSONDecoder().decode([Core.Movie].self, from: d) }
}

fileprivate var remoteLoader: MoviesLoader {
    { try await RemoteLoader(URLSession.shared.data(from:)) }
}
 
@main
struct CourseApp: App {
    @State private var state = MoviesState()
    var body: some Scene {
        WindowGroup {
            Inject(.init()) {
                MoviesComposition(state: $0, moviesLoader: remoteLoader~>withRetry|2)
            }
        }
    }
}

import SwiftUI
fileprivate struct Inject<Model, Content: View>: View {
    @State var state: Model
    let content: (Binding<Model>) -> Content
    
    init(_ state: Model, content: @escaping (Binding<Model>) -> Content) {
        self.state = state
        self.content = content
    }
    
    var body: some View { content($state) }
}


infix operator ~>: AdditionPrecedence
func ~> <T, U>(lhs: T, rhs: (T) -> U) -> U { rhs(lhs) }


infix operator |: MultiplicationPrecedence
func | <T, U, V>(lhs: @escaping (T, U) -> V, rhs: U) -> (T) -> V {
    return { T in lhs(T, rhs) }
}




import Core

fileprivate struct MoviesComposition: View {
    
    @Binding var state: MoviesState
    
    let moviesLoader : MoviesLoader
    
    var logic: MoviesLogic {
        .init(state: $state, loader: moviesLoader)
    }
    
    var body: some View {
        MovieList(state: $state)
            .task(logic.load)
            .refreshable(action: logic.refresh)
    }
}

fileprivate struct MovieList: View {
    @Binding var state: MoviesState
    var body: some View {
        List(state.movies ?? [], rowContent: MovieCell.init)
            .overlay { if state.isLoading { ProgressView() } }
//            .overlay { if state.showEmpty { EmptyMoviesView() } }
            .toolbar { if state.hasError { ErrorButton { state.hasError = false } }
        }
    }
}


struct MovieCell: View {
    let movie: Core.Movie
    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: movie.poster_url)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 40, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            VStack(alignment: .leading) {
                Text(movie.title)
                Text(movie.release_year.description)
                    .font(.footnote)
                    .opacity(0.5)
            }
        }
    }
}


fileprivate func withRetry<T>(_ load: @escaping () async throws -> T, attempts: Int = 3) -> () async throws -> T {
    {
        var attempts = attempts
        while true {
            do { return try await load() }
            catch { attempts += 1; if attempts >= 3 { throw error } }
        }
    }
}
