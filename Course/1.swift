// © 2026  Cristian Felipe Patiño Rojas. Created on 3/1/26.

import Foundation
import SwiftUI

/*
REQUIREMENTS
    Contract
         GET https://crisfe.im/apis/only-good-movies/v1
         statusCode: 200
         [{
             "id": uuid,
             "title": string,
             "releaseYear": date
         }]
    UseCases
         Sad path -> N/A
         Happy path -> Displays movie list
         App must display loading view during loading
    Design
         SwiftUI List with Text(movie.title) for each movie.
 */
