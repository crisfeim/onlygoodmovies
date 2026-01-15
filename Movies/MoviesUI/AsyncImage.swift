// © 2026  Cristian Felipe Patiño Rojas. Created on 15/1/26.

import SwiftUI

@MainActor
struct AsyncImage<Content: View>: View {
    
    @Environment(\.imagesStore) var store
    @Environment(\.imagesLoader) var loader
    
    @ViewBuilder let content: (AsyncImagePhase) -> Content
    
    let url: URL?
    @State private var result: AsyncImageLogic.Result?
    
    var logic: AsyncImageLogic {
        .init(url: url, result: $result, store: store, loader: loader)
    }
    
    var body: some View {
        ZStack {
            switch result {
            case .none: content(.empty).task(logic.download)
            case .success(let image): content(.success(image))
            case .failure(let error): content(.failure(error))
            }
        }.onAppear(perform: logic.load)
    }
}


extension EnvironmentValues {
    @Entry var imagesStore: ImagesStore?
    @Entry var imagesLoader: ImagesLoader?
}
