// © 2026  Cristian Felipe Patiño Rojas. Created on 5/1/26.


import SwiftUI


fileprivate protocol LoadingView {
    func displayLoading(_ bool: Bool)
}

fileprivate class Presenter {
    let view: LoadingView
    init(view: LoadingView) {
        self.view = view
    }
    
    func load() {
        view.displayLoading(true)
    }
}


@Observable
fileprivate class ObservableIsLoading {
    var isLoading = false
}

fileprivate struct LoadingSwiftUIView: View, LoadingView {
    @State var observable = ObservableIsLoading()
    var body: some View {
        Text(observable.isLoading.description)
    }
    
    func displayLoading(_ bool: Bool) {
        observable.isLoading = bool
    }
}

fileprivate struct LoadingSwiftUIView_2: View, LoadingView {
    @State var isLoading = false
    var body: some View {
        Text(isLoading.description)
    }
    
    func displayLoading(_ bool: Bool) {
        isLoading = bool
    }
}


fileprivate func compose() -> some View {
    let v = LoadingSwiftUIView()
    let p = Presenter(view: v)
    return v.onAppear(perform: p.load)
}

fileprivate func compose_2() -> some View {
    let v = LoadingSwiftUIView_2()
    let p = Presenter(view: v)
    return v.onAppear(perform: p.load)
}

fileprivate struct LoadingSwiftUIView_3: View, LoadingView {
    @Binding var isLoading: Bool
    var body: some View {
        Text(isLoading.description)
    }
    
    func displayLoading(_ bool: Bool) {
        isLoading = bool
    }
}

@Observable fileprivate class Observable<T> {
    var value: T
    
    init(_ value: T) {
        self.value = value
    }
}



fileprivate func compose_4() -> some View {
    struct Container: View {
        @State var isLoading = false
        var body: some View {
            let v = LoadingSwiftUIView_3(isLoading: $isLoading)
            let p = Presenter(view: v)
            return v.onAppear(perform: p.load)
        }
    }
    return Container()
}



fileprivate func compose_3() -> some View {
    @State var isLoading = Observable(false)
    let v = LoadingSwiftUIView_3(isLoading: $isLoading.value)
    let p = Presenter(view: v)
    return v.onAppear(perform: p.load)
}

fileprivate func compose_5() -> some View {
    @State var isLoading = Observable(false)
    let v = LoadingSwiftUIView_3(isLoading: $isLoading.value)
    let p = Presenter(view: v)
    return v.onAppear(perform: p.load)
}


#Preview {
    compose_3()
}
