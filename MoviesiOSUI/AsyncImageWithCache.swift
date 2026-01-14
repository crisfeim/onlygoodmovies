// © 2026  Cristian Felipe Patiño Rojas. Created on 14/1/26.

import SwiftUI
import Movies

public struct AsyncImageWithCache: View {
    @Environment(EnvironmentImageCache.self) var cache
    let url: URL?
    
    public var body: some View {
        if let url, let image = cache.get(url) {
            Image(uiImage: image).resizable()
        } else {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .task { await loadImage() }
                default: Rectangle().foregroundColor(.gray.opacity(0.5))
               }
            }
        }
    }
    
    func loadImage() async {
       if let url, let (d, _) = try? await URLSession.shared.data(from: url), let image = UIImage(data: d) {
            cache.cache(url, image)
        }
    }
}

