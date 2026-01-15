// © 2026  Cristian Felipe Patiño Rojas. Created on 12/1/26.
import SwiftUI
import Movies

struct MovieCellController {
    let movie: Movie
    func loadImage() {}
}

struct MovieCell: View {
    let movie: Movie
    var body: some View {
        HStack(spacing: 12) {
            if let url = URL(string: movie.posterURL) {
                MoviePoster(url: url)
            }
            VStack(alignment: .leading) {
                Text(movie.title)
                Text(movie.releaseYear.description)
                    .font(.footnote)
                    .opacity(0.5)
            }
        }
    }
}

import UIKit


fileprivate struct MoviePoster: View {
    let url: URL
    
    var body: some View {
       AsyncImageWithCache(url: url)
        .aspectRatio(contentMode: .fill)
        .frame(width: 40, height: 60)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        
    }
}

 struct Shimmer: ViewModifier {
    @State var isInitialState: Bool = true
    private let color = Color.white
    
    func body(content: Content) -> some View {
        content
            .overlay {
                LinearGradient(
                    gradient: .init(colors: [.clear, color.opacity(0.6), .clear]),
                    startPoint: (isInitialState ? .init(x: -1, y: -1) : .init(x: 1, y: 1)),
                    endPoint: (isInitialState ? .init(x: 0, y: 0) : .init(x: 2, y: 2))
                )
            }
            .animation(.linear(duration: 1.5).delay(0.25).repeatForever(autoreverses: false), value: isInitialState)
            .onAppear() {
                isInitialState = false
            }
    }
}


#Preview(traits: .sizeThatFitsLayout) {
    MovieCell(movie: mockMovie()).padding()
}

