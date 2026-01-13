// © 2026  Cristian Felipe Patiño Rojas. Created on 8/1/26.


import SwiftUI

struct ErrorButton: ToolbarContent {
    let action: () -> Void
    
    #if os(iOS)
    var body: some ToolbarContent {
        ToolbarItem(placement: .bottomBar) {
            Button(action: action)
        }
    }
    #endif
    
    var body: some ToolbarContent {
        ToolbarItem {}
    }
    
    fileprivate struct Button: View {

        let action: () -> Void
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
                }
            }
        }
    }
    
    return PreviewView()
}

