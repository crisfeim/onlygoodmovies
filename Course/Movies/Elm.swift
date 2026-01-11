// © 2026  Cristian Felipe Patiño Rojas. Created on 11/1/26.

// MODELO
struct MovieModel {
    var movies: [Movie] = []
    var error: String?
}

// MENSAJES
enum MovieMsg {
    case load
    case receiveMovies([Movie])
    case receiveError
}

// UPDATE
func update(msg: MovieMsg, model: MovieModel) -> (MovieModel, MovieCmd) {
    var m = model
    switch msg {
    case .load:
        return (m, .urlRequest)
        
    case .receiveMovies(let movies):
        m.movies = movies
        return (m, .none)
        
    case .receiveError:
        m.error = "Fallo de red"
        return (m, .none)
    }
}

fileprivate struct MovieList: View {
    let model: MovieModel
    let update: (MovieMsg) -> Void
    var body: some View {
        List(model.movies, rowContent: Cell.init)
            .onAppear {
                update(.load)
            }
    }
}

// COMANDOS
enum MovieCmd {
    case none
    case urlRequest
}


import SwiftUI

@MainActor
@Observable
class ElmRuntime<Model, Msg, Cmd> {
    private(set) var model: Model
    private let update: (Msg, Model) -> (Model, Cmd)
    private let perform: (Cmd) async -> Msg?
    
    // El "embudo" para los comandos
    private var commandQueue = Task { }

    init(initialModel: Model,
         update: @escaping (Msg, Model) -> (Model, Cmd),
         perform: @escaping (Cmd) async -> Msg?) {
        self.model = initialModel
        self.update = update
        self.perform = perform
    }

    func send(_ msg: Msg) {
        // 1. Update atómico (sincrónico)
        let (nextModel, cmd) = update(msg, model)
        self.model = nextModel
        
        // 2. Serialización de Comandos (Efectos)
        // Encadenamos la nueva tarea a la anterior para asegurar el orden
        let currentJob = commandQueue
        commandQueue = Task {
            _ = await currentJob.value // Espera a que el comando anterior termine
            if let nextMsg = await perform(cmd) {
                send(nextMsg)
            }
        }
    }
}
