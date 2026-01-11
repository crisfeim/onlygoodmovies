// © 2026  Cristian Felipe Patiño Rojas. Created on 10/1/26.

import SwiftUI


extension View {
    func taskOnChangeOf<ID: Hashable>(id: ID?, _ action: @escaping () async -> Void) -> some View {
        self.task(id: id) {
            guard id != nil else { return }
            await action()
        }
    }
}

struct AsyncButton: View {
    let label: String
    let action: () async -> Void
    
    init(_ label: String, action: @escaping () async -> Void) {
        self.label = label
        self.action = action
    }
    
    @State private var isRunning = false
    var body: some View {
        Button(label) {
            isRunning = true
        }
        .task(id: isRunning) {
            guard !isRunning else { return }
            await action()
            isRunning = false
        }
        .disabled(isRunning)
    }
}


fileprivate struct Example: View {
    @State var loaded = false
    @State var isLoading = false
    var body: some View {
        VStack {
            Text(loaded ? "Loaded" : "Not loaded")
            if isLoading {
                ProgressView()
            }
            
            AsyncButton("Load") {
                try? await Task.sleep(for: .seconds(2))
                loaded = true
                isLoading = false
            }
        }
    }
}

#Preview {
    Example()
}


// Enum equivalency:

fileprivate enum Phase_Sum_Type<T> {
    case loading
    case loaded(T)
    case error(String)
}

fileprivate struct Phase_Product_Type<T> {
    var isLoading: Bool {
        data == nil && error == nil
    }
    
    private(set) var data: T?
    private(set) var error: String?
    
    mutating func setData(_ data: T) {
        self.data = data
    }
    
    mutating func setLoading() {
        data = nil
        error = nil
    }
    
    mutating func setError(_ error: String) {
        self.error = error
    }
}
