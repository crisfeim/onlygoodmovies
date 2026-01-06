// © 2026  Cristian Felipe Patiño Rojas. Created on 4/1/26.

struct Movie: Identifiable, Decodable {
    let id: String
    let title: String
    let poster_url: String
    let release_year: Int
}

import SwiftUI

struct MovieCell: View {
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


struct ErrorView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.title)
                .opacity(0.6)
            Text("Unable to load")
        }
    }
}

struct MoviesEmptyView: View {
    var body: some View {
        Image(systemName: "film.stack")
            .font(.title)
            .opacity(0.6)
    }
}
