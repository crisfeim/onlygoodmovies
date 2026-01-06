import SwiftUI
import Observation


// MARK: - Presentation Protocols
extension MoviesPresenter {
    @MainActor protocol LoadingView { func displayLoading(_ bool: Bool) }
    @MainActor protocol ErrorView { func displayError(_ message: String?) }
    @MainActor protocol MovieListView { func displayMovies(_ movies: [Movie]) }
}

// MARK: - Store
fileprivate struct MoviesStore {
    var errorMessage: String?
    var isLoading = false
    var movies: [Movie]?
    var showEmpty: Bool { movies != nil && (movies ?? []).isEmpty }
}

// MARK: - ViewModel (The "Bridge")
@Observable @MainActor
fileprivate class MoviesViewModel {
    var store = MoviesStore()
}

extension MoviesViewModel: MoviesPresenter.MovieListView, MoviesPresenter.ErrorView, MoviesPresenter.LoadingView {
    func displayMovies(_ movies: [Movie]) { store.movies = movies }
    func displayError(_ message: String?) { store.errorMessage = message }
    func displayLoading(_ bool: Bool) { store.isLoading = bool }
}

// MARK: - Presenter
@MainActor
fileprivate class MoviesPresenter {
    let loader: MoviesLoader
    let listView: MovieListView
    let errorView: ErrorView
    let loadingView: LoadingView

    init(loader: MoviesLoader, listView: MovieListView, errorView: ErrorView, loadingView: LoadingView) {
        self.loader = loader
        self.listView = listView
        self.errorView = errorView
        self.loadingView = loadingView
    }

    func load() async {
        loadingView.displayLoading(true)
        do {
            let movies = try await loader.load()
            listView.displayMovies(movies)
            loadingView.displayLoading(false)
        } catch {
            errorView.displayError(error.localizedDescription)
            loadingView.displayLoading(false)
        }
    }
}

// MARK: - Views
fileprivate struct MoviesList: View {
    let viewModel: MoviesViewModel
    
    var body: some View {
        NavigationStack {
            List {
                if let movies = viewModel.store.movies {
                    ForEach(movies) { movie in
                        MovieCell(movie: movie)
                    }
                }
            }
            .navigationTitle("Movies")
            .overlay { if viewModel.store.isLoading { ProgressView() } }
            .overlay { if let error = viewModel.store.errorMessage { Text(error) } }
            .overlay { if viewModel.store.showEmpty { Image(systemName: "film.stack").font(.largeTitle).opacity(0.5) } }
        }
    }
}

fileprivate struct MovieCell: View {
    let movie: Movie
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: movie.poster_url)) { img in img.resizable().aspectRatio(contentMode: .fill) }
            placeholder: { Color.gray.opacity(0.2) }
            .frame(width: 50, height: 75).clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(alignment: .leading) {
                Text(movie.title).bold()
                Text("\(movie.release_year)").font(.caption).foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Loader Protocol
fileprivate protocol MoviesLoader {
    func load() async throws -> [Movie]
}

// MARK: - Composition Root
@MainActor
fileprivate func compose(loader: MoviesLoader) -> some View {
    let viewModel = MoviesViewModel()
    let presenter = MoviesPresenter(
        loader: loader,
        listView: viewModel,
        errorView: viewModel,
        loadingView: viewModel
    )
    return MoviesList(viewModel: viewModel)
        .task { await presenter.load() }
}

// MARK: - Preview
#Preview {
     struct MockLoader: MoviesLoader {
        func load() async throws -> [Movie] {
            try? await Task.sleep(for: .seconds(2)) // Simulamos red
            return [Movie(id: "1", title: "Inception", poster_url: "https://via.placeholder.com/150", release_year: 2010)]
        }
    }
    return compose(loader: MockLoader())
}
