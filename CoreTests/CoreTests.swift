// © 2026  Cristian Felipe Patiño Rojas. Created on 3/1/26.

import XCTest
import SwiftUI

final class CoreTests: XCTestCase {

//    func test_1() throws {
//        XCTExpectFailure {
//            let view = LoadingUIKitViewController()
//            let presenter = Presenter(loadingView: view)
//            view.delegate = Weak<Presenter>(presenter).object
//            trackForMemoryLeaks(presenter)
//            trackForMemoryLeaks(view)
//        }
//    }
//    
//    func test_2() throws {
//        XCTExpectFailure {
//            let view = LoadingUIKitViewController()
//            let presenter = Presenter(loadingView: view)
//            let wire = { [weak presenter] in
//                view.delegate = presenter
//            }
//            wire()
//            trackForMemoryLeaks(presenter)
//            trackForMemoryLeaks(view)
//        }
//    }
//    
    func test_3() throws {
        let view = LoadingUIKitViewController()
        let presenter = Presenter(loadingView: Weak(view))
        view.delegate = presenter
        trackForMemoryLeaks(presenter)
        trackForMemoryLeaks(view)
    }
   

    // 📁 composition
    // |- PresenterAdapter
    // |- LoadingUIComposer -> LoadingUIKitViewController
    // 📁 Host app
    // import Infrastructure
    // import LoadingUI
    // import LoadingPresentation
    // |- AppDelegate, SceneDelegate, @main...
    
    // 📦 Infrastructure -> Loader / Servie
    // 📦 LoadingUIKitViewController --> xcframweork, swift package
    // 📦 Presentation
    
    func test_4() throws {
        let view = LoadingUIKitViewController() // <- ui
        let presenter = Presenter(loadingView: Weak(view)) // <- presentation
        let adapter = PresenterAdapter(presenter: presenter) // <- composition
    
        view.delegate = adapter
        trackForMemoryLeaks(presenter)
        trackForMemoryLeaks(view)
    }
}


protocol LoadingView {
    func displayLoading(shouldDisplay: Bool)
}

class LoadingUIKitViewController: LoadingView {
    protocol Delegate { func didLoad() }
    var delegate: Delegate?
    func displayLoading(shouldDisplay: Bool) {}
    
    func didLoad() {
        delegate?.didLoad()
    }
}

struct LoadingSwiftUIView: View, LoadingView {
    var body: some View {}
    
    func displayLoading(shouldDisplay: Bool) {}
}

class Presenter {
    let loadingView: LoadingView
    func load() {}
    init(loadingView: LoadingView) {
        self.loadingView = loadingView
    }
}

extension Presenter:  LoadingUIKitViewController.Delegate  {
    func didLoad() {}
}

class PresenterAdapter: LoadingUIKitViewController.Delegate  {
    let presenter: Presenter
    init(presenter: Presenter) {
        self.presenter = presenter
    }
    
    func didLoad() {
        presenter.load()
    }
}

class Weak<T: AnyObject> {
    weak var object: T?
    
    init(_ object: T) {
        self.object = object
    }
}

extension Weak: LoadingView where T:LoadingView {
    func displayLoading(shouldDisplay: Bool) {
        object?.displayLoading(shouldDisplay: shouldDisplay)
    }
}


extension XCTestCase {
    func trackForMemoryLeaks(
        _ instance: AnyObject,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
        }
    }
}
