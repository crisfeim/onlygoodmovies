// © 2026  Cristian Felipe Patiño Rojas. Created on 3/1/26.

#if DEBUG
import Foundation
import Movies

func mockMovie() -> Movie {
    Movie(
        id: "17",
        title: "The Passion of the Christ",
        posterURL: "https://crisfe.im/apis/only-good-movies/passionofchrist.png",
        releaseYear: 2004
    )
}

func anyError() -> Error {
    NSError(domain: "any-error", code: 0)
}
#endif

