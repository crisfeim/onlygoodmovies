// © 2026  Cristian Felipe Patiño Rojas. Created on 15/1/26.
import SwiftUI

typealias ImagesStore = (URL) -> Image?
typealias ImagesLoader = (URL) async throws -> Image?

struct AsyncImageLogic {
    typealias Result = Swift.Result<Image, Error>
    struct ImageDecodingError: Error {}
    let url: URL?
    @Binding var result: Result?
    let store: ImagesStore
    let loader: ImagesLoader
    func load() {
        guard result == nil, let url, let image = store(url) else { return }
        self.result = .success(image)
    }
    
    func download() async {
        guard let url, result == nil else { return }
        do {
            guard let image = try await loader(url) else {
                result = .failure(ImageDecodingError())
                return
            }
            result = .success(image)
        } catch {
            result = .failure(error)
        }
      
    }
}
