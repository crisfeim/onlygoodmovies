// © 2026  Cristian Felipe Patiño Rojas. Created on 14/1/26.

import SwiftUI
import Movies

public struct AsyncImageWithCache: View {
   
    @State var image: UIImage? = nil
    
    static let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .returnCacheDataElseLoad
        config.urlCache = URLCache(
            memoryCapacity: 50*1024*1024,
            diskCapacity: 100*1024*1024,
            diskPath: "images"
        )
        return URLSession(configuration: config)
    }()
    
    let url: URL?
    public var body: some View {
    Rectangle()
        .fill(Color.gray.opacity(0.3))
        .overlay {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
        }
        .onAppear {
            if let url, let cachedResponse = Self.session.configuration.urlCache?.cachedResponse(for: URLRequest(url: url)),
               let cachedImage = UIImage(data: cachedResponse.data) {
                self.image = cachedImage
                return
            }
        }
        .task(id: url) {
            if let url, let (data, _) = try? await Self.session.data(from: url),
               let downloadedImage = UIImage(data: data) {
               self.image = downloadedImage
            }
        }
    }
}
