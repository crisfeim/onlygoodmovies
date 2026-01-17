// © 2026  Cristian Felipe Patiño Rojas. Created on 15/1/26.
import SwiftUI

@MainActor
@Observable class ResourceImageCoordinator {
    struct ImageDecodingError: Error {}
    let url: URL?
    var phase: AsyncImagePhase
    let store: ImagesStore?
    let loader: ImagesLoader?
    
    init(phase: AsyncImagePhase, url: URL?, store: ImagesStore?, loader: ImagesLoader?) {
        self.url = url
        self.store = store
        self.loader = loader
        
        let image =  url.flatMap { store?($0) }
        let p = image.flatMap { AsyncImagePhase.success($0) }
        self.phase = p ?? phase
    }
    
    func download() async {
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
