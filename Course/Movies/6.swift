// © 2026  Cristian Felipe Patiño Rojas. Created on 3/1/26.

/*
 Requirements
 GET tmbdb
 */

import SwiftUI

fileprivate struct Count: View {
    @State var store: Store
    var body: some View {
        Button(store.count.description) { store.count += 1 }
    }
}

@Observable @MainActor fileprivate class Store {
    var count = 0
    let loader: Loader
    
    init(loader: Loader) {
        self.loader = loader
    }
    
    func load() async {}
    func refresh() async {}
}

fileprivate protocol Loader {}

fileprivate struct CountComposer: View {
    let store: Store
    
    init(loader: Loader) {
        self.store = Store(loader: loader)
    }
    
    var body: some View {
        Count(store: store)
            .task(store.load)
            .refreshable(action: store.refresh)
    }
}

fileprivate struct PreviewLoader: Loader {}
fileprivate let loader = PreviewLoader()

#Preview {
    CountComposer(loader: PreviewLoader())
}

fileprivate struct Composer<T, V: View>: View {
    @State var value: T
    let view: V
    var body: some View {view}
}


fileprivate func composition() -> some View {
    @State var test = ""
    return Text(test).onAppear { test = "hello world"}
}

fileprivate struct Composer_2<T, V: View>: View {
    @Binding var value: T
    let view: V
    var body: some View {view}
}


@MainActor
fileprivate func composition_2() -> some View {
    @State var text = ""
    return Composer(value: text, view: Text(text)).onAppear { text = "hello world" }
}

fileprivate protocol LoadingView {
    func displayLoading(_ bool: Bool)
}

#Preview {
    composition_2()
}
