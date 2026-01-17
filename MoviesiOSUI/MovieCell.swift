// © 2026  Cristian Felipe Patiño Rojas. Created on 12/1/26.
import SwiftUI
import Movies

public struct MovieCell<Thumbnail: View>: View {
    let movie: Movie
    let thumbnailProvider: (URL?) -> Thumbnail
    public var body: some View {
        HStack(spacing: 12) {
            thumbnailProvider(URL(string: movie.posterURL))
            VStack(alignment: .leading) {
                Text(movie.title)
                Text(movie.releaseYear.description)
                    .font(.footnote)
                    .opacity(0.5)
            }
        }
    }
}

public extension MovieCell<AsyncImage<MovieThumbnail>> {
    static func `default`(_ movie: Movie) -> Self {
        MovieCell(movie: movie) {
            AsyncImage(url: $0,  content: MovieThumbnail.init)
        }
    }
}

public struct MovieThumbnail: View {
    let phase: AsyncImagePhase
    
    public var body: some View {
        ZStack {
            switch phase {
            case .success(let image): image.resizable()
            default:  Rectangle().foregroundColor(.gray).modifier(Shimmer())
            }
        }
        .animation(.linear, value: phase.image)
        .aspectRatio(contentMode: .fill)
        .frame(width: 40, height: 60)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

 struct Shimmer: ViewModifier {
    @State private var isInitialState: Bool = true
    
    func body(content: Content) -> some View {
        content
            .overlay {
                LinearGradient(
                    gradient: .init(colors: [.clear, Color.white.opacity(0.6), .clear]),
                    startPoint: (isInitialState ? .init(x: -1, y: -1) : .init(x: 1, y: 1)),
                    endPoint: (isInitialState ? .init(x: 0, y: 0) : .init(x: 2, y: 2))
                )
                .animation(.linear(duration: 1.5).delay(0.25).repeatForever(autoreverses: false), value: isInitialState)
                .onAppear() {
                    isInitialState = false
                }
            }
            .mask(content)
            
    }
}


#Preview(traits: .sizeThatFitsLayout) {
    MovieCell(movie: mockMovie()) { _ in MovieThumbnail(phase: .empty) }.padding()
}

