import SwiftUI

/*
Since this solution involves a call site (our wrapper)
that could break on state additions (we would need to manually
add state to both, the wrapper & the view) we could
protect our solution from breaking changes by by grouping
our state into a unified store.
 */
struct Movielist_4_Store {
    
   // Centralized state
   // La firma de la vista no cambia al añadir estado.
   // Mantiene call sites y previews funcionales (no se rompen)
    var isLoading = false
    var movies = [Movie]()
    var errorMessage: String?
}

struct MovieList_4: View {
    // This could be a dumb model
    // with no binding.
    // Though, for each action
    // the view wants to perform over
    // state we would need to pass a closure
    // which is not inherently bad as
    // it's another level of decoupling.
    @Binding var store: Store

    var body: some View {
        List(store.movies) { movie in
            Text(movie.title)
        }
        .overlay(alignment: .top) {
            if store.isLoading { ProgressView() }
        }
        .overlay(alignment: .bottom) {
            Button(store.errorMessage ?? "") { store.errorMessage = nil }
                .foregroundColor(.red)
        }
    }
}

extension MovieList_4 {
    typealias Store = Movielist_4_Store
}

struct MovieList_4_Wrapper: View {
    @State var store = Movielist_4_Store()
    let loader: () async throws -> [Movie]
    var body: some View {
        MovieList_4(store: $store)
            .refreshable(action: load)
            .task(initLoad)
        }
        
    func load() async {
        do {
            store.errorMessage = nil
            store.isLoading = true
            store.movies = try await loader()
            store.isLoading = false
        } catch {
            store.errorMessage = error.localizedDescription
            store.isLoading = false
        }
    }
    
    func initLoad() async {
        guard store.movies.isEmpty else { return }
        await load()
    }
}

// We could use an @Observable store, which allows
// moving state control logic to the store itself and test
// state mutations through asserts:
@Observable class Movielist_5_Store {
    var isLoading = false
    var movies = [Movie]()
    var errorMessage: String?
    
    func refresh(with loader: () async throws -> [Movie]) async {
       await load(with: loader)
    }
    
    func initLoad(with loader: () async throws -> [Movie]) async {
        guard movies.isEmpty else { return }
        await load(with: loader)
    }
    
    private func load(with loader: () async throws -> [Movie]) async {
        defer { isLoading = false }
        do {
            errorMessage = nil
            isLoading = true
            movies = try await loader()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

struct MovieList_5: View {
    @Bindable var store: Store

    var body: some View {
        List(store.movies) { movie in
            Text(movie.title)
        }
        .overlay(alignment: .top) {
            if store.isLoading { ProgressView() }
        }
        .overlay(alignment: .bottom) {
            Button(store.errorMessage ?? "") { store.errorMessage = nil }
                .foregroundColor(.red)
        }
    }
}

extension MovieList_5 {
    typealias Store = Movielist_5_Store
}

struct MovieList_5_Wrapper: View {
    @State var store = Movielist_5_Store()
    let loader: () async throws -> [Movie]
    var body: some View {
        MovieList_5(store: store)
            .refreshable(action: refresh)
            .task(initLoad)
        }
        
    func refresh() async {
        await store.refresh(with: loader)
    }
    
    func initLoad() async {
        await store.initLoad(with: loader)
    }
}

 /*
  But this is a less ergonomic as we need to manually param inject the loader into the store.
  
  Estaría bien que pudieramos omitirlo, pero para eso necesitamos que @Store sea construido con una referencia a loader...
  */

@Observable class Movielist_6_Store {
    var isLoading = false
    var movies = [Movie]()
    var errorMessage: String?
    
    let loader: () async throws -> [Movie]
    
    init(loader: @escaping () async throws -> [Movie]) {
        self.loader = loader
    }
    
    func refresh() async {
       await load()
    }
    
    func initLoad() async {
        guard movies.isEmpty else { return }
        await load()
    }
    
    private func load() async {
        defer { isLoading = false }
        do {
            isLoading = true
            movies = try await loader()
        } catch {
            errorMessage = "Connection error"
        }
    }
}

struct MovieList_6: View {
    @Bindable var store: Store

    var body: some View {
        List(store.movies) { movie in
            Text(movie.title)
        }
        .overlay(alignment: .top) {
            if store.isLoading { ProgressView() }
        }
        .toolbar {
            if let errorMessage = store.errorMessage {
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        store .errorMessage = nil
                    } label: {
                        HStack(spacing: 16) {
                            Text(errorMessage)
                                .frame(maxWidth: 200)
                            Image(systemName: "xmark")
                                .scaleEffect(0.7)
                                .foregroundColor(.black)
                        }
                    }
                    .tint(Color.red)
                }
            }
        }
    }
}

extension MovieList_6 {
    typealias Store = Movielist_6_Store
}


enum MovieList_6_Composer {
    static func compose(loader: @escaping () async throws -> [Movie]) -> some View {
        let store = Movielist_6_Store(loader: loader)
        let view = MovieList_6(store: store)
        return view
            .refreshable(action: store.refresh)
            .task(store.initLoad)
    }
}

#Preview("Unified store") {
    var isFirstLoad = true
    MovieList_6_Composer.compose {
        try await Task.sleep(for: .seconds(1))
        if isFirstLoad {
            isFirstLoad = false
            return [mockMovie()]
        } else {
            throw anyError()
        }
    }
}
