//
//  MockMovieService.swift
//  NeuGelbTests
//
//  Created by EMRE on 2.12.2021.
//

import Foundation
import Combine
@testable import NeuGelb

class MockMovieService: MovieServiceProtocol {
    var getMovieCallsCount: Int = 0
    var getFavoriteCallsCount: Int = 0
    
    var getMovieResult: Result<Response<Movie>, Error> = .success(Response<Movie>(results: []))
    var getFavoriteResult: Result<Response<Favorite>, Error> = .success(Response<Favorite>(results: []))
    
    func fetchMovies() -> AnyPublisher<Response<Movie>, Error> {
        getMovieCallsCount += 1
        return getMovieResult.publisher.eraseToAnyPublisher()
    }
    
    func fetchFavorites() -> AnyPublisher<Response<Favorite>, Error> {
        getFavoriteCallsCount += 1
        return getFavoriteResult.publisher.eraseToAnyPublisher()
    }
}
