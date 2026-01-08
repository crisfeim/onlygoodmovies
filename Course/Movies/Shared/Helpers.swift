// © 2026  Cristian Felipe Patiño Rojas. Created on 3/1/26.

func anyMovie(id: String = "0", title: String = "Any movie") -> Movie {
    Movie(
        id: id,
        title: title,
        poster_url: "https://crisfe.im/apis/only-good-movies/passionofchrist.png",
        release_year: 2004
    )
}

func mockMovie() -> Movie {
    Movie(
        id: "17",
        title: "The Passion of the Christ",
        poster_url: "https://crisfe.im/apis/only-good-movies/passionofchrist.png",
        release_year: 2004
    )
}

import Foundation

func anyError() -> Error {
    NSError(domain: "any-error", code: 0)
}

import SwiftUI


struct ErrorView: View {
    var body: some View {
        ContentUnavailableView("Something went wrong", systemImage: "exclamationmark.triangle")
    }
}

struct EmptyMoviesView: View {
    var body: some View {
        ContentUnavailableView("Movies", systemImage: "film.stack")
    }
}


struct Cell: View {
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

