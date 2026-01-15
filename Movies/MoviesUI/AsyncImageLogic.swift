// © 2026  Cristian Felipe Patiño Rojas. Created on 15/1/26.
import SwiftUI

public typealias ImagesStore = (URL) -> Image?
public typealias ImagesLoader = (URL) async throws -> Image?

@MainActor
public struct AsyncImageLogic {
    public typealias Result = Swift.Result<Image, Error>
    struct ImageDecodingError: Error {}
    let url: URL?
    @Binding var result: Result?
    let store: ImagesStore?
    let loader: ImagesLoader?
    
    public init(url: URL?, result: Binding<Result?>, store: ImagesStore?, loader: ImagesLoader?) {
        self.url = url
        self._result = result
        self.store = store
        self.loader = loader
    }
    
    public func load() {
        guard result == nil, let url, let image = store?(url) else { return }
        self.result = .success(image)
    }
    
    public func download() async {
        guard let url, result == nil else { return }
        do {
            guard let image = try await loader?(url) else {
                result = .failure(ImageDecodingError())
                return
            }
            result = .success(image)
        } catch {
            result = .failure(error)
        }
      
    }
}
