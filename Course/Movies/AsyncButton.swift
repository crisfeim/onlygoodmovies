// © 2026  Cristian Felipe Patiño Rojas. Created on 10/1/26.

import SwiftUI

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


#Preview {
    struct Example: View {
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

    return Example()
}
