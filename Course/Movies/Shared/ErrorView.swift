// © 2026  Cristian Felipe Patiño Rojas. Created on 12/1/26.

import SwiftUI

struct ErrorView: View {
    var body: some View {
        ContentUnavailableView("Something went wrong", systemImage: "exclamationmark.triangle")
    }
}

#Preview("ErrorView", traits: .sizeThatFitsLayout) {
    ErrorView()
}
