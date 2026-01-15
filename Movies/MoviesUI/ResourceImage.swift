// © 2026  Cristian Felipe Patiño Rojas. Created on 15/1/26.

import SwiftUI

@MainActor
public struct ResourceImage<Content: View>: View {
    
    @Environment(\.imagesStore) var store
    @Environment(\.imagesLoader) var loader
    
    let content: (AsyncImagePhase) -> Content
    let url: URL?
    
    @State private var phase = AsyncImagePhase.empty
    
    var logic: ResourceImageLogic {
        .init(url: url, phase: $phase, store: store, loader: loader)
    }
    
    public init(url: URL?, @ViewBuilder content: @escaping (AsyncImagePhase) -> Content) {
        self.content = content
        self.url = url
    }
    
    public var body: some View {
        content(phase)
            .task(logic.download)
            .onAppear(perform: logic.load)
    }
}


public extension EnvironmentValues {
    @Entry var imagesStore: ImagesStore?
    @Entry var imagesLoader: ImagesLoader?
}
