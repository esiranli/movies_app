//
//  Movie.swift
//  NeuGelb
//
//  Created by EMRE on 1.12.2021.
//

import Foundation

struct Movie: Decodable {
    let backdropPath: String
    let id: Int
    let originalLanguage: String
    let originalTitle: String
    let overview: String
    let popularity: Double
    let posterPath: String
    let title: String
    let rating: Double
    let releaseDate: String
    let isWatched: Bool
}

extension Movie: Comparable {
    static func < (lhs: Movie, rhs: Movie) -> Bool {
        return (lhs.rating, rhs.title) < (rhs.rating, lhs.title)
    }
}

struct Favorite: Decodable {
    let id: Int
}

struct Response<T: Decodable>: Decodable {
    let results: [T]
}
