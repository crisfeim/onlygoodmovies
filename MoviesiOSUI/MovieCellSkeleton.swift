// © 2026  Cristian Felipe Patiño Rojas. Created on 17/1/26.
import SwiftUI

#Preview {
    MovieCell(movie: mockMovie()) { url in
        MovieThumbnail(phase: .empty)
    }
    .redacted(reason: .placeholder)
}
