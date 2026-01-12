// © 2026  Cristian Felipe Patiño Rojas. Created on 12/1/26.

import SwiftUI

struct EmptyMoviesView: View {
    var body: some View {
        ContentUnavailableView("Movies", systemImage: "film.stack")
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    EmptyMoviesView()
}
