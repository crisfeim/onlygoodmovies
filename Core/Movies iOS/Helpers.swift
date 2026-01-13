// © 2026  Cristian Felipe Patiño Rojas. Created on 3/1/26.

func anyMovie(id: String = "0", title: String = "Any movie") -> RemoteMovie {
    RemoteMovie(
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
        posterURL: "https://crisfe.im/apis/only-good-movies/passionofchrist.png",
        releaseYear: 2004
    )
}

import Foundation

func anyError() -> Error {
    NSError(domain: "any-error", code: 0)
}
