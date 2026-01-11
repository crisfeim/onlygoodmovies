// © 2026  Cristian Felipe Patiño Rojas. Created on 11/1/26.

import SwiftUI
import XCTest

struct CounterState {
    var count = 0
}

struct CounterLogic {
    @Binding var state: CounterState
    
    func increase() {
        state.count += 1
    }
    
    func decrease() {
        state.count -= 1
    }
}

struct CounterView {
    @Binding var count: Int
    var body: some View {
        Text("count")
    }
    
    func increase() { count += 1 }
    func decrease() { count -= 1 }
}


class BindingTest: XCTestCase {
    func test() {
        var state = CounterState()
        let binding = Binding(get: { state }, set: { state = $0 })
        let sut = CounterLogic(state: binding)
        sut.increase()
        XCTAssertEqual(state.count, 1)
    }
    
    struct CounterStored: View  {
        @AppStorage var count_stored: Int
        var body: some View {
            CounterView(count: $count_stored)
        }
    }
    
    
    struct CounterView: View {
       
        @Binding var count: Int
        var body: some View {
            Text("count")
        }
        
        var increase: () -> Void { {count += 1} }
        var decrease: () -> Void { {count -= 1} }
    }

    
    func test_2() {
        let binding = makeBinding(0)
        let sut = CounterView(count: binding)
        sut.increase()
        XCTAssertEqual(binding.wrappedValue, 1)
    }
    
    func makeBinding<T>(_ value: T) -> Binding<T> {
       var value = value
       return Binding(get: { value }, set: { value = $0 })
    }

}

struct Test {
//    func increment() {}
    let increment: () -> Void
//    var action: () -> Void { increment() }
}
