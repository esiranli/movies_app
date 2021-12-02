//
//  MovieCardViewModel.swift
//  NeuGelb
//
//  Created by EMRE on 30.11.2021.
//

import Foundation
import Combine

class MovieCardViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var imageUrl: String = ""
    @Published var description: String = ""
    @Published var rating: Double = 0
    @Published var date: String = ""
    @Published var language: String = ""
    @Published var id: Int = -1
    
    private let movie: Movie
    
    init(movie: Movie) {
        self.movie = movie
        self.id = movie.id
        self.name = movie.title
        self.imageUrl = movie.backdropPath
        self.description = movie.overview
        self.rating = movie.rating
        self.date = movie.releaseDate
        self.language = movie.originalLanguage
    }
}
