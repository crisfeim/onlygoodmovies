// © 2026  Cristian Felipe Patiño Rojas. Created on 12/1/26.

import Movies
import SwiftUI

public struct MovieCell<Thumbnail: View>: View {
    let movie: Movie
    let thumbnail: (URL?) -> Thumbnail
    
    public init(movie: Movie, thumbnail: @escaping (URL?) -> Thumbnail) {
        self.movie = movie
        self.thumbnail = thumbnail
    }
    
    public var body: some View {
        HStack(spacing: 12) {
            thumbnail(URL(string: movie.posterURL))
            VStack(alignment: .leading) {
                Text(movie.title)
                Text(movie.releaseYear.description)
                    .font(.footnote)
                    .opacity(0.5)
            }
        }
    }
}

public struct MovieThumbnail: View {
    let phase: AsyncImagePhase
    
    public init(phase: AsyncImagePhase) {
        self.phase = phase
    }
    
    public var body: some View {
        ZStack {
            switch phase {
            case .success(let image): image.resizable()
            default: Rectangle()
                    .foregroundColor(.gray)
                    .opacity(0.3)
                    .modifier(Shimmer())
            }
        }
        .animation(.linear, value: phase.image)
        .aspectRatio(contentMode: .fill)
        .frame(width: 40, height: 60)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}



#Preview(traits: .sizeThatFitsLayout) {
    MovieCell(movie: mockMovie()) { _ in MovieThumbnail(phase: .empty) }.padding()
}

