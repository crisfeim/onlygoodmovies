// © 2026  Cristian Felipe Patiño Rojas. Created on 15/1/26.

import SwiftUI

@MainActor
public struct ResourceImage<Content: View>: View {
    @Environment(\.imagesStore) var store
    @Environment(\.imagesLoader) var loader
    
    let content: (AsyncImagePhase) -> Content
    let url: URL?
    
    public init(url: URL?, @ViewBuilder content: @escaping (AsyncImagePhase) -> Content) {
        self.content = content
        self.url = url
    }
    
    public var body: some View {
        Root(url: url, store: store, loader: loader, content: content)
    }
}

private extension ResourceImage {
    @MainActor
    struct Root: View {
        let content: (AsyncImagePhase) -> Content
        let url: URL?

        @State var coordinator: ResourceImageCoordinator
        
        public init(url: URL?, store: ImagesStore?, loader: ImagesLoader?, @ViewBuilder content: @escaping (AsyncImagePhase) -> Content) {
            self.content = content
            self.url = url
            coordinator = .init(phase: .empty, url: url, store: store, loader: loader)
        }
        
        public var body: some View {
            content(coordinator.phase).task(coordinator.download)
        }
    }
}

public typealias ImagesStore  = @Sendable (URL) -> Image?
public typealias ImagesLoader = @Sendable (URL) async throws -> Image?

public extension EnvironmentValues {
    @Entry var imagesStore: ImagesStore?
    @Entry var imagesLoader: ImagesLoader?
}
