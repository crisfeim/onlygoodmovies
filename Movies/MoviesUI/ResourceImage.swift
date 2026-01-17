// © 2026  Cristian Felipe Patiño Rojas. Created on 15/1/26.

import SwiftUI

@MainActor
public struct ResourceImage<Content: View>: View {
    private let content: (AsyncImagePhase) -> Content
    private let url: URL?

    @State private var coordinator: ResourceImageCoordinator
    
    public init(url: URL?, store: ImagesStore?, loader: ImagesLoader?, @ViewBuilder content: @escaping @MainActor (AsyncImagePhase) -> Content) {
        self.content = content
        self.url = url
        coordinator = .init(phase: .empty, url: url, store: store, loader: loader)
    }
    
    public var body: some View {
        content(coordinator.phase).task(coordinator.download)
    }
}

public typealias ImagesStore  = @Sendable (URL) -> Image?
public typealias ImagesLoader = @Sendable (URL) async throws -> Image?
