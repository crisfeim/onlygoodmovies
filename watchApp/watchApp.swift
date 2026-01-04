// © 2026  Cristian Felipe Patiño Rojas. Created on 4/1/26.

import Foundation
import SwiftUI


fileprivate struct MovieList: View {
    enum ViewState {
        case loading
        case loaded([Movie])
        case error(String)
    }
    
    @State var state = ViewState.loading
    var body: some View {
        switch state {
        case .loading: ProgressView().task(load)
        case .loaded(let movies): List(movies, rowContent: cell)
        case .error(let error): Text(error)
        }
    }
    
    func cell(_ m: Movie) -> some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: m.poster_url)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            VStack(alignment: .leading) {
                Text(m.title)
                Text(m.release_year.description)
                    .font(.footnote)
                    .opacity(0.5)
            }
        }
    }
    
    func load() async {
        do {
            let (d, _) = try await URLSession.shared.data(from: URL(string: "https://crisfe.im/apis/only-good-movies/v1")!)
            let decoded = try JSONDecoder().decode([Movie].self, from: d)
            state = .loaded(decoded)
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}

#Preview {
    MovieList()
}
