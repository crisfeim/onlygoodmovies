// © 2026  Cristian Felipe Patiño Rojas. Created on 8/1/26.


import SwiftUI

struct ErrorButton: ToolbarContent {
    let action: () -> Void
    var body: some ToolbarContent {
        ToolbarItem(placement: .bottomBar) {
            Button(action: action)
        }
    }
    
    fileprivate struct Button: View {

        let action: () -> Void
        @State var opacity = 1.0
        var body: some View {
            SwiftUI.Button {
               action()
            } label: {
                HStack {
                    Image(systemName: "exclamationmark.triangle")
                    Text("Something went wrong")
                        .frame(maxWidth: 200)
                    Image(systemName: "xmark")
                        .scaleEffect(0.7)
                        .foregroundColor(.black)
                        .padding(.leading)
                }
            }
            .tint(Color.gray)
            .opacity(opacity)
            .animation(.default, value: opacity)
            .task {
                try? await Task.sleep(for: .seconds(3))
//                opacity = 0
                try? await Task.sleep(for: .seconds(0.5))
                action()
            }
        }
    }
}


#Preview {
    
    struct PreviewView: View {
        @State var shown = true
        var body: some View {
            VStack {
                Button("Restart") {
                    shown = true
                }
               
            }
            .animation(.default, value: shown)
            .toolbar {
                if shown {
                    ErrorButton { shown = false }
                } else {
                    ToolbarItem(placement: .bottomBar) {
                        Button("") {}
                    }
                }
            }
        }
    }
    
    return PreviewView()
}

