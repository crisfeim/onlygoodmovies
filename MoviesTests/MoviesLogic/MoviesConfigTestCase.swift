import SwiftUI
import XCTest
import Movies


@MainActor
class MoviesConfigTestCase: XCTestCase {
    
    func test_loadResetsConfigOnLoaderFailure() async {
        let (sut, config) = makeSUT() { throw anyError() }
        await sut.load()
        XCTAssertEqual(config(), .init())
    }
    
    func test_loadDisplayPlaceholdersWhileLoading() async {
        let config = BindingConfigSpy(MoviesConfig())
        let anyState = makeBinding(MoviesState())
        let sut = MoviesLogic(anyState, config.binding, loader: anyLoader())
        await sut.load()
        XCTAssertEqual(config.capturedConfig.first?.reason, .placeholder)
    }
    
    func makeSUT(_ state: MoviesConfig = MoviesConfig(), loader: @escaping MoviesLoader = anyLoader()) -> (MoviesLogic, () -> MoviesConfig) {
        let config = makeBinding(state)
        let anyState = makeBinding(MoviesState())
        return (MoviesLogic(anyState, config, loader: loader), { config.wrappedValue })
    }
}

fileprivate class BindingConfigSpy {
    var capturedConfig: [MoviesConfig] = []
    private let initConfig: MoviesConfig
    
    init(_ initConfig: MoviesConfig) {
        self.initConfig = initConfig
    }
    
    @MainActor
    var binding: Binding<MoviesConfig> {
        .init(get: { self.initConfig }, set: { self.capturedConfig.append($0) })
    }
}
