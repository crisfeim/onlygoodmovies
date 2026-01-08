// © 2026  Cristian Felipe Patiño Rojas. Created on 8/1/26.

import SwiftUI


extension MoviesList {
    @Observable class Store {
        var showError = false
        var isLoading = true
        var movies: [Movie]?
        
        var showEmpty: Bool {
            movies != nil && (movies ?? []).isEmpty
        }
    }
}

fileprivate struct MoviesList: View {
    @State var store = Store()
    var body: some View {
        List {
            ForEach(store.movies ?? []) { Cell(movie: $0) }
        }
        .overlay { if store.isLoading { ProgressView() } }
        .overlay { if store.showError { ErrorView()    } }
        .overlay { if store.showEmpty { EmptyView()    } }
    }
}

// Presentation module
extension MoviesPresenter {
    protocol LoadingView {
        func displayLoading(_ bool: Bool)
    }

    protocol ErrorView {
        func displayError(_ show: Bool)
    }

    protocol ListView {
        func displayMovies(_ movies: [Movie])
    }
}

@MainActor
fileprivate class MoviesPresenter {
    let loader     : MoviesLoader
    let listView   : ListView
    let errorView  : ErrorView
    let loadingView: LoadingView
    
    init(
        loader     : MoviesLoader,
        listView   : ListView,
        errorView  : ErrorView,
        loadingView: LoadingView
    ) {
        self.loader = loader
        self.listView = listView
        self.errorView = errorView
        self.loadingView = loadingView
    }
    
    
    func load() async {
        do {
            loadingView.displayLoading(true)
            listView.displayMovies(try await loader.load())
            loadingView.displayLoading(false)
        } catch {
            errorView.displayError(true)
            loadingView.displayLoading(false)
        }
    }
    
    func refresh() async {
        do {
            errorView.displayError(false)
            listView.displayMovies(try await loader.load())
            loadingView.displayLoading(false)
        } catch {
            errorView.displayError(true)
        }
    }
}

extension MoviesList: MoviesPresenter.LoadingView {
    func displayLoading(_ bool: Bool) {
        store.isLoading = bool
    }
}

extension MoviesList: MoviesPresenter.ListView {
    func displayMovies(_ movies: [Movie]) {
        store.movies = movies
    }
}

extension MoviesList: MoviesPresenter.ErrorView {
    func displayError(_ show: Bool) {
        store.showError = show
    }
}


fileprivate protocol MoviesLoader {
    func load() async throws -> [Movie]
}

fileprivate enum MovieListComposer {
    
    @MainActor
     static func compose(loader l: MoviesLoader) -> some View {
        let v = MoviesList()
        
        let p = MoviesPresenter(
            loader: l,
            listView: v,
            errorView: v,
            loadingView: v
        )
        
        return v
            .task(p.load)
            .refreshable(action: p.refresh)
    }
}

#Preview {
    class MockLoader: MoviesLoader {
        func load() async throws -> [Movie] {
            try await Task.sleep(for: .seconds(2))
            return [mockMovie()]
        }
    }

    return MovieListComposer.compose(loader: MockLoader())
}

