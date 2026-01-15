// © 2026  Cristian Felipe Patiño Rojas. Created on 14/1/26.

import SwiftUI

public struct AsyncImageWithCache: View {
    fileprivate class DefaultImageSession: ImageSession {
        let session: URLSession = {
            let config = URLSessionConfiguration.default
            config.requestCachePolicy = .returnCacheDataElseLoad
            config.urlCache = URLCache(
                memoryCapacity: 50*1024*1024,
                diskCapacity: 150*1024*1024,
                diskPath: "movie_images"
            )
            return URLSession(configuration: config)
        }()
        
        func downloadImage(from url: URL) async throws -> UIImage? {
            let (d, _) = try await session.data(from: url)
            return UIImage(data: d)
        }
        
        func getCachedImage(for url: URL) -> UIImage? {
            let req = URLRequest(url: url)
            guard
            let res = session.configuration.urlCache?.cachedResponse(for: req),
            let image = UIImage(data: res.data) else { return nil }
            return image
        }
    }
    
    private static let session = DefaultImageSession()
    
    let url: URL?
    
    public var body: some View {
        Content(url: url)
        .environment(\.imageSession, Self.session)
    }
}

fileprivate struct Content: View {
    @Environment(\.imageSession) private var imageSession
    @State private var image: UIImage?
    let url: URL?
    var body: some View {
    Rectangle()
        .fill(Color.gray.opacity(0.3))
        .modifier(Shimmer())
        .overlay {
            if let image {
               Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
       
        .onAppear {
            if let url, let cached = imageSession?.getCachedImage(for: url) {
                image = cached
            }
        }
        .task(id: url) {
            guard image == nil else { return }
            if let url, let downloadedImage = try? await imageSession?.downloadImage(from: url)  {
                withAnimation(.linear) {
                    image = downloadedImage
                }
            }
        }
    }
}

fileprivate extension EnvironmentValues {
    @Entry var imageSession: ImageSession?
}

fileprivate protocol ImageSession {
    func downloadImage(from url: URL) async throws -> UIImage?
    func getCachedImage(for url: URL) -> UIImage?
}

#Preview("Image loading transition") {
     class MockCache: ImageSession {
        func downloadImage(from url: URL) async throws -> UIImage? {
            try await Task.sleep(for: .seconds(2))
            return UIImage.image(with: .red)
        }
        
        func getCachedImage(for url: URL) -> UIImage? { nil }
    }
    
   return Content(url: URL(string: "anyurl"))
        .environment(\.imageSession, MockCache())
        .frame(width: 40, height: 60)
        .clipShape(RoundedRectangle(cornerRadius: 8))
}

#if DEBUG
fileprivate extension UIImage {
    static func image(with color: UIColor) -> UIImage {
        let rect = CGRect(origin: CGPoint(x: 0, y:0), size: CGSize(width: 1, height: 1))
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()!

        context.setFillColor(color.cgColor)
        context.fill(rect)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image!
    }
}
#endif
