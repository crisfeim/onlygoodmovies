// © 2026  Cristian Felipe Patiño Rojas. Created on 15/1/26.
import SwiftUI

public typealias ImagesStore = (URL) -> Image?
public typealias ImagesLoader = (URL) async throws -> Image?

@MainActor
public struct AsyncImageLogic {
    public typealias Result = Swift.Result<Image, Error>
    struct ImageDecodingError: Error {}
    let url: URL?
    @Binding var phase: AsyncImagePhase
    let store: ImagesStore?
    let loader: ImagesLoader?
    
    public init(url: URL?, phase: Binding<AsyncImagePhase>, store: ImagesStore?, loader: ImagesLoader?) {
        self.url = url
        self._phase = phase
        self.store = store
        self.loader = loader
    }
    
    public func load() {
        guard phase.image == nil, let url, let image = store?(url) else { return }
        phase = .success(image)
    }
    
    public func download() async {
        guard let url, phase.image == nil else { return }
        do {
            guard let image = try await loader?(url) else {
                phase = .failure(ImageDecodingError())
                return
            }
            phase = .success(image)
        } catch {
            phase = .failure(error)
        }
      
    }
}

fileprivate extension AsyncImagePhase {
    var image: Image? {
        switch self {
        case .success(let i): return i
        default: return nil
        }
    }
}
