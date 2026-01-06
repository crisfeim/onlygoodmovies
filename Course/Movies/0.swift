// © 2026  Cristian Felipe Patiño Rojas. Created on 4/1/26.

// © 2026  Cristian Felipe Patiño Rojas. Created on 4/1/26.

import Foundation
import SwiftUI

/*
 1. Naive implementation
    1. Better previews through dependency injection
    2. Preview intermediary states through control logic decoupling
 2. Pull to refresh: Sum type to product type.
     2. Abstracting state into a unified store.
        1. Value type
        2. Testing control logic: Reference type
 2. Introduction to composition
    1. Composing through SwiftUI
    2. Composing through functions
    3. Composition root
 3. New screen with different data source: Decoupling from DTO
 3. Platform specific views: a watchOS app. The MVP pattern.
 4. Introduction to the MVP pattern
    4. Screen with different sections: Composition with Mini MVPs
    4. Switch view implementation & parallel develoment.
 6. Nothing new under the sun: On universal patterns.
    1. Show composite with RealityKit/SceneKit & UIKit.
    2. Demos source code (Rescript + VanJS) side by side comparaison with Swift+SwiftUI implementation.
 7. Conclusions
    7. What's next: Navigation?
 8. Colophon
    1. iOS Essential Developer
    2. Written in Xcode (link to project)
    2. Made with Bun, Rescript, VanJS, Vanilla CSS. (code source?)
 */
extension MovieList {
    enum Phase {
        case loading
        case loaded([Movie])
        case error
    }
}

fileprivate struct MovieList: View {
    
    @State var phase = Phase.loading
    let load: () async throws -> [Movie]
    
    // Could be a different struct if needed
    @ViewBuilder
    static func list(phase: Phase) -> some View {
        switch phase {
        case .loading: ProgressView()
        case .loaded(let movies): Loaded(movies: movies)
        case .error: ErrorView()
        }
    }
    
    
    var body: some View {
        Self.list(phase: phase)
            .task(load)
    }
    
    
    func load() async {
        do {
            let movies = try await load()
            phase = .loaded(movies)
        } catch {
            phase = .error
        }
    }
    
    fileprivate struct Loaded: View {
        let movies: [Movie]
        var body: some View {
            List(movies, rowContent: MovieCell.init)
                .overlay {
                    if movies.isEmpty {
                        MoviesEmptyView()
                    }
                }
        }
    }
}

#Preview("Loading") {
    MovieList.list(phase: .loading)
}

#Preview("Loaded") {
    MovieList.list(phase: .loaded([
        Movie(
            id: "17",
            title: "The Passion of the Christ",
            poster_url: "https://crisfe.im/apis/only-good-movies/passionofchrist.png",
            release_year: 2004
        )
    ]))
}

#Preview("Error") {
    MovieList.list(phase: .error)
}


#Preview("Empty") {
    MovieList.list(phase: .loaded([]))
}



fileprivate struct ErrorView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.title)
                .opacity(0.6)
            Text("Unable to load")
        }
    }
}

fileprivate struct MoviesEmptyView: View {
    var body: some View {
        Image(systemName: "film.stack")
            .font(.title)
            .opacity(0.6)
    }
}


fileprivate struct MovieCell: View {
    let movie: Movie
    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: movie.poster_url)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 40)
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
