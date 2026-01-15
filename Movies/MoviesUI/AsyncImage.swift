// © 2026  Cristian Felipe Patiño Rojas. Created on 15/1/26.

import SwiftUI

@MainActor
struct AsyncImage<Content: View>: View {
    
    @Environment(\.imagesStore) var store
    @Environment(\.imagesLoader) var loader
    
    @ViewBuilder let content: (AsyncImagePhase) -> Content
    
    let url: URL?
    @State private var phase: AsyncImagePhase
    
    var logic: AsyncImageLogic {
        .init(url: url, phase: $phase, store: store, loader: loader)
    }
    
    struct UnhandledCase: Error {}
    var body: some View {
        ZStack {
            switch phase {
            case .empty: content(.empty).task(logic.download)
            case .success(let image): content(.success(image))
            case .failure(let error): content(.failure(error))
            @unknown default: content(.failure(UnhandledCase()))
            }
        }.onAppear(perform: logic.load)
    }
}


extension EnvironmentValues {
    @Entry var imagesStore: ImagesStore?
    @Entry var imagesLoader: ImagesLoader?
}
