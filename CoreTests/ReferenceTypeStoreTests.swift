//// © 2026  Cristian Felipe Patiño Rojas. Created on 8/1/26.
///*
// 
// Preguntas:
// 
// Debería mover las variables a un modelo y compartirlo con la vista  (eliminando el protocolo Model)?:
// 
// struct MovieList.Model {
//    var movies = [String]()
//    var showLoading = true
//    var showEmpty = false
//    var showError = false
// }
// 
// @Observable class MovieListStore {
//    private(set) var model = Model()
// 
//    func load()
//    func refresh()
//    func displayError()
//    func dismishError()
//    func displayLoading()
// }
// */
//fileprivate typealias Movie = String
//import XCTest
//
//fileprivate protocol MoviesLoader {
//    func load() async throws -> [Movie]
//}
//
//@Observable
//fileprivate class MovieListStore {
//    private(set) var movies = [String]()
//    private(set) var showLoading = true
//    private(set) var showEmpty = false
//    private(set) var showError = false
//    
//    private let loader: MoviesLoader
//    
//    init(loader: MoviesLoader) {
//        self.loader = loader
//    }
//    func load() async {
//        do {
//            displayMovies(try await loader.load())
//        } catch {
//            displayError()
//        }
//    }
//    
//    func refresh() async {
//        dismissError()
//        await load()
//    }
//    
//    func displayError() {
//        showLoading = false
//        showError = true
//    }
//    
//    func dismissError() {
//        showError = false
//    }
//    
//    func displayMovies(_ movies: [Movie]) {
//        self.movies = movies
//        showLoading = false
//        showEmpty = movies.isEmpty
//        showError = false
//    }
//}
//
//class ReferenceTypeStoreTests: XCTestCase {
//
//    fileprivate struct DummyLoader: MoviesLoader { func load() async throws -> [Movie] {[]} }
//    
//    fileprivate struct StubLoader: MoviesLoader {
//        let stub: Result<[String], Error>
//        func load() async throws -> [Movie] {try stub.get()}
//        
//        init(data: [String]) {
//            stub = .success(data)
//        }
//        
//        init(error: Error) {
//            stub = .failure(error)
//        }
//    }
//    
//    
//    func test_initWithLoadingState() async {
//        let sut = MovieListStore(loader: DummyLoader())
//        XCTAssertEqual(sut.movies, [])
//        XCTAssertTrue(sut.showLoading)
//        XCTAssertFalse(sut.showEmpty)
//        XCTAssertFalse(sut.showError)
//    }
//    
//    func test_loadShowsEmptyOnSuccessWithEmptyData() async {
//        let sut = MovieListStore(loader: DummyLoader())
//        await sut.load()
//        XCTAssertEqual(sut.movies, [])
//        XCTAssertFalse(sut.showLoading)
//        XCTAssertTrue(sut.showEmpty)
//        XCTAssertFalse(sut.showError)
//    }
//    
//    func test_loadShowsDataSuccessWithData() async {
//       
//        let sut = MovieListStore(loader: StubLoader(data: ["hello world"]))
//        await sut.load()
//        XCTAssertEqual(sut.movies, ["hello world"])
//        XCTAssertFalse(sut.showLoading)
//        XCTAssertFalse(sut.showEmpty)
//        XCTAssertFalse(sut.showError)
//    }
//    
//    func test_loadShowsErrorOnError() async {
//        let sut = MovieListStore(loader: StubLoader(error: anyError()))
//        await sut.load()
//        XCTAssertEqual(sut.movies, [])
//        XCTAssertFalse(sut.showLoading)
//        XCTAssertFalse(sut.showEmpty)
//        XCTAssertTrue(sut.showError)
//    }
//    
//    func test_refreshHidesErrorAfterFailureThenSuccess() async {
//        
//         class StubLoader: MoviesLoader {
//             var stubs: [Result<[String], Error>]
//             
//             init(stubs:  [Result<[String], Error>]) { self.stubs = stubs }
//             
//            func load() async throws -> [Movie] {
//                defer { stubs.removeFirst() }
//                let current = try stubs.first?.get() ?? []
//                return current
//            }
//        }
//        
//        let loader = StubLoader(stubs: [
//            .failure(anyError()),
//            .success(["Hello"])
//        ])
//        
//        let sut = MovieListStore(loader: loader)
//        await sut.load()
//        XCTAssertTrue(sut.showError)
//        await sut.refresh()
//        XCTAssertEqual(sut.movies, ["Hello"])
//        XCTAssertFalse(sut.showError)
//    }
//    
//    private func anyError() -> NSError {
//        NSError(domain: "any-error", code: 0)
//    }
//}
