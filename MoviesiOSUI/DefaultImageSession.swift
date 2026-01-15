// © 2026  Cristian Felipe Patiño Rojas. Created on 14/1/26.

import UIKit

fileprivate class DefaultImageSession {
    fileprivate let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .returnCacheDataElseLoad
        config.urlCache = URLCache(
            memoryCapacity: 50*1024*1024,
            diskCapacity: 150*1024*1024,
            diskPath: "images"
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
