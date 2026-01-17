// © 2026  Cristian Felipe Patiño Rojas. Created on 15/1/26.

import SwiftUI

@MainActor
func makeBinding<T>(_ value: T) -> Binding<T> {
   var value = value
    return Binding(get: {
        value
    }, set: {
        value = $0
    })
}


func anyURL() -> URL? {
    URL(string: "https://any-url.com")
}
