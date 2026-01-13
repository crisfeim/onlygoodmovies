// © 2026  Cristian Felipe Patiño Rojas. Created on 12/1/26.
import SwiftUI
import Core

struct MovieCell: View {
    let movie: Movie
    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: movie.posterURL)) { image in
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
                Text(movie.releaseYear.description)
                    .font(.footnote)
                    .opacity(0.5)
            }
        }
    }
}


#Preview(traits: .sizeThatFitsLayout) {
    MovieCell(movie: mockMovie()).padding()
}
