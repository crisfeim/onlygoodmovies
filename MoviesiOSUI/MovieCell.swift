// © 2026  Cristian Felipe Patiño Rojas. Created on 12/1/26.
import SwiftUI
import Movies

struct MovieCell: View {
    let movie: Movie
    var body: some View {
        HStack(spacing: 12) {
            MoviePoster(path: movie.posterURL)
            VStack(alignment: .leading) {
                Text(movie.title)
                Text(movie.releaseYear.description)
                    .font(.footnote)
                    .opacity(0.5)
            }
        }
    }
}

fileprivate struct MoviePoster: View {
    let path: String
    
    var body: some View {
        ResourceImage(url: URL(string: path)) { phase in
            switch phase {
            case .success(let image): image.resizable()
            case .failure: Text("Error")
            default: ProgressView()
            }
        }
        .aspectRatio(contentMode: .fill)
        .frame(width: 40, height: 60)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

 struct Shimmer: ViewModifier {
    @State private var isInitialState: Bool = true
    let isActive: Bool
    
    func body(content: Content) -> some View {
        content
            .overlay {
                if isActive {
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
            }
            .mask(content)
            
    }
}


#Preview(traits: .sizeThatFitsLayout) {
    MovieCell(movie: mockMovie()).padding()
}

