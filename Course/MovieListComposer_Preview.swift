// © 2026  Cristian Felipe Patiño Rojas. Created on 18/1/26.
import Movies
import MoviesiOSUI
import SwiftUI

// Previews

#Preview("App") {
    @Previewable @State var id = UUID()
    
    let mockMovie = { @Sendable in
        Movie(
            id: "17",
            title: "The Passion of the Christ",
            posterURL: "https://crisfe.im/apis/only-good-movies/passionofchrist.png",
            releaseYear: 2004
        )
    }
    class PreviewHelper {
        nonisolated(unsafe) var shouldSucceed = false
    }
   
   return MovieListComposer(
        loader: {
           let helper = PreviewHelper()
           return  AsyncThrowingStream { continuation in
                Task {
                    guard helper.shouldSucceed else {
                        helper.shouldSucceed = true
                        return continuation.finish(throwing: NSError(domain: "any-error", code:0))
                    }
                    Array(0...10).map{_ in mockMovie() }.forEach { movie in
                        continuation.yield(movie)
                    }
                    helper.shouldSucceed = false
                    continuation.finish()
                }
            }
        },
        thumbnail: AsyncImage<MovieThumbnail>.init
    )
    .id(id)
    .toolbar {
        ToolbarItem(placement: .bottomBar) {
            Button("Reload") { id = UUID() }
        }
    }
}
