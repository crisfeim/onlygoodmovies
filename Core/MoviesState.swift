// © 2026  Cristian Felipe Patiño Rojas. Created on 13/1/26.


import SwiftUI

public struct MoviesState {
    public var movies: [RemoteMovie]
    public var showError: Bool
    public var showLoading: Bool
    public var showEmpty: Bool
    
    public init() {
        movies = []
        showLoading = true
        showError = false
        showEmpty = false
    }
    
    public init(movies: [RemoteMovie], showLoading: Bool, showError: Bool, showEmpty: Bool) {
        self.movies = movies
        self.showLoading = showLoading
        self.showError = showError
        self.showEmpty = showEmpty
    }
}
