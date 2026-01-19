import Movies
import SwiftUI
import XCTest

@MainActor
class MoviesConfigTestCase: XCTestCase {
    
    func test_loadResetsConfigOnLoadingFailure() async {
        let (sut, config) = makeSUT() { throw anyError() }
        await sut.firstLoad()
        XCTAssertEqual(config.currentValue, .idle)
    }
    
    func test_loadSetsConfigLoadingWhileLoading() async {
        let (sut, config) = makeSUT()
        await sut.firstLoad()
        XCTAssertEqual(config.capturedConfig.first, .loading)
    }
    
    func test_loadResetsConfigOnLoadingSuccess() async {
        let (sut, config) = makeSUT()
        await sut.firstLoad()
        XCTAssertEqual(config.capturedConfig.last, .idle)
    }
    
    fileprivate func makeSUT(_ config: MoviesConfig = MoviesConfig(), loader: @escaping MoviesLoader = anyLoader()) -> (sut: MoviesPresenter, config: BindingConfigSpy) {
        let config = BindingConfigSpy(config)
        let anyState = makeBinding(MoviesState())
        return (MoviesPresenter(anyState, config.binding, loader: loader), config)
    }
}

fileprivate class BindingConfigSpy {
    var capturedConfig: [MoviesConfig] = []
    var currentValue: MoviesConfig? { capturedConfig.last }
    private let initConfig: MoviesConfig
    
    init(_ initConfig: MoviesConfig) {
        self.initConfig = initConfig
    }
    
    @MainActor
    var binding: Binding<MoviesConfig> {
        .init(get: { self.initConfig }, set: { self.capturedConfig.append($0) })
    }
}
