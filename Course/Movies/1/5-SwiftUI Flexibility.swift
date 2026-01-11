// © 2026  Cristian Felipe Patiño Rojas. Created on 6/1/26.

import Core
import SwiftUI

fileprivate struct MovieListController: View {
    @State var view = MovieList.loading
    let load: () async throws -> [Movie]
    var body: some View { view.task(load) }
    
    func load() async {
        do {
            view = .loaded(try await load())
        } catch {
            view = .error
        }
    }
}

fileprivate enum MovieList: View {
    case loading
    case loaded([Movie])
    case error
    
    var body: some View {
        switch self {
        case .loading: ProgressView()
        case .loaded(let list): list
        case .error: ErrorView()
        }
    }
}

extension [Movie]: @retroactive View {
    public var body: some View {
        List(self) { $0 }
            .overlay {
                if self.isEmpty {
                    EmptyMoviesView()
                }
            }
    }
}

extension Movie: View {
    public var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: poster_url)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                ProgressView()
            }
            .frame(width: 40)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            VStack(alignment: .leading) {
                Text(title)
                Text(release_year.description)
                    .font(.footnote)
                    .opacity(0.5)
            }
        }
    }
}
