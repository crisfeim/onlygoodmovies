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

struct ErrorButton: View {
    let label: String
    let action: () -> Void
    var body: some View {
        Button {
           action()
        } label: {
            HStack(spacing: 16) {
                Text(label)
                    .frame(maxWidth: 200)
                Image(systemName: "xmark")
                    .scaleEffect(0.7)
                    .foregroundColor(.black)
            }
        }
        .tint(Color.red)
    }
}
