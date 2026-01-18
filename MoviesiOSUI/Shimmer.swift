// © 2026  Cristian Felipe Patiño Rojas. Created on 18/1/26.

import SwiftUI

struct Shimmer: ViewModifier {
   @State private var isInitialState: Bool = true
   
   func body(content: Content) -> some View {
       content
           .mask {
               LinearGradient(
                gradient: .init(colors: [Color.white.opacity(0.5), Color.white, Color.white.opacity(0.5)]),
                   startPoint: (isInitialState ? .init(x: -1, y: -1) : .init(x: 1, y: 1)),
                   endPoint: (isInitialState ? .init(x: 0, y: 0) : .init(x: 2, y: 2))
               )
               .animation(.linear(duration: 1.5).delay(0.25).repeatForever(autoreverses: false), value: isInitialState)
               .onAppear() {
                   isInitialState = false
               }
           }
   }
}
