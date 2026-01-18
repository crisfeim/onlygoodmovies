// © 2026  Cristian Felipe Patiño Rojas. Created on 18/1/26.
import Movies
import MoviesiOSUI
import SwiftUI

// Previews

#Preview("App") {
    @Previewable @State var id = UUID()
    
    var shouldFail = false
    let movie = Movie(
        id: "17",
        title: "The Passion of the Christ",
        posterURL: "https://crisfe.im/apis/only-good-movies/passionofchrist.png",
        releaseYear: 2004
    )
  
    MovieListComposer(
        loader: {@MainActor in
        try await Task.sleep(for: .seconds(2))
        
        if shouldFail {
            shouldFail = false
            throw NSError(domain: "any-error", code: 0)
        } else {
            shouldFail = true
            return Array(0...10).map {_ in movie }
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
