// © 2026  Cristian Felipe Patiño Rojas. Created on 6/1/26.

import SwiftUI

fileprivate struct MovieListController: View {
    @State var phase = MovieList.Phase.loading
    let loader: () async throws -> [Movie]
    
    var body: some View {
        MovieList(phase: phase, onErrorTap: {
            phase.displayError(false)
        })
        .task(load)
        .refreshable(action: refresh)
    }
    
    func load() async {
        do {
            phase = .loaded(try await loader(), showError: false)
        } catch {
            phase.displayError(true)
        }
    }
    
    func refresh() async {
        phase.displayError(false)
        await load()
    }
}



fileprivate struct MovieList: View {
    let phase: Phase
    let onErrorTap: () -> Void
    var body: some View {
        switch phase {
        case .loading: ProgressView()
        case .loaded(let movies, let showError):
            List(movies, rowContent: Cell.init)
                .overlay {
                    if movies.isEmpty {
                        EmptyMoviesView()
                    }
                }
                .toolbar {
                    if showError {
                        ErrorButton(action: onErrorTap)
                    }
                }
        }
    }
}

extension MovieList {
    enum Phase: Equatable {
        case loading
        case loaded([Movie], showError: Bool)
        
        var movies: [Movie]? {
            switch self {
            case .loaded(let m, _): return m
            default: return nil
            }
        }
        
        mutating func displayError(_ bool: Bool) {
            if let movies {
                self = .loaded(movies, showError: bool)
                return
            }
            
            self = .loaded([], showError: bool)
        }
    }
}


#Preview("Controller") {
    var shouldFail = false
    MovieListController {
        try await Task.sleep(for: .seconds(2))
        
        if shouldFail {
            print("should fail")
            shouldFail = false
            throw anyError()
        } else {
            print("should not fail")
            shouldFail = true
            return [mockMovie(), mockMovie()]
        }
    }
}


#Preview("Loading") {
    MovieList(phase: .loading, onErrorTap: {})
}
#Preview("Loaded") {
    MovieList(phase: .loaded([mockMovie()], showError: false), onErrorTap: {})
}
#Preview("Empty") {
    MovieList(phase: .loaded([], showError: false), onErrorTap: {})
}
#Preview("Loaded + Error") {
    MovieList(phase: .loaded([mockMovie()], showError: true), onErrorTap: {})
}
#Preview("Empty + Error") {
    MovieList(phase: .loaded([], showError: true), onErrorTap: {})
}
