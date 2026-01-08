// © 2026  Cristian Felipe Patiño Rojas. Created on 8/1/26.


import SwiftUI

struct ErrorButton: ToolbarContent {
    let action: () -> Void
    var body: some ToolbarContent {
        ToolbarItem(placement: .bottomBar) {
            Button(label: "Something went wrong", action: action)
        }
    }
    
    fileprivate struct Button: View {
        let label: String
        let action: () -> Void
        var body: some View {
            SwiftUI.Button {
               action()
            } label: {
                HStack(spacing: 16) {
                    Text(label)
                        .frame(maxWidth: 200)
                    Image(systemName: "xmark")
                        .scaleEffect(0.7)
                        .foregroundColor(.black)
                }
            }
            .tint(Color.red)
        }
    }
}



