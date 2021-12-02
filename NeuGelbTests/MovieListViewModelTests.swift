//
//  MovieListViewModelTests.swift
//  NeuGelbTests
//
//  Created by EMRE on 2.12.2021.
//

import Foundation
import XCTest
import Combine
@testable import NeuGelb

enum MockError: Error {
    case error
}

class MovieListViewModelTests: XCTestCase {
    private var subject: MovieListViewModel!
    private var mockMovieService: MockMovieService!
    private var cancellables: Set<AnyCancellable> = []
    
    override func setUp() {
        super.setUp()
        
        mockMovieService = MockMovieService()
        subject = MovieListViewModel(service: mockMovieService)
    }
    
    override func tearDown() {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        mockMovieService = nil
        subject = nil
    }
    
    func test_getMovie_shouldCallService() {
        //when
        subject.getMovies()
        
        //then
        XCTAssertGreaterThan(mockMovieService.getMovieCallsCount, 0)
        XCTAssertGreaterThan(mockMovieService.getFavoriteCallsCount, 0)
        XCTAssertEqual(mockMovieService.getMovieCallsCount, 1)
        XCTAssertEqual(mockMovieService.getFavoriteCallsCount, 1)
    }
    
    func test_getMovies_givenServiceCallSucceeds_shouldUpdateMovies() {
        // given
        mockMovieService.getMovieResult = .success(Response<Movie>(results: Constant.movies))
        mockMovieService.getFavoriteResult = .success(Response<Favorite>(results: Constant.favorites))
        
        // when
        subject.getMovies()
        
        // then
        XCTAssertEqual(mockMovieService.getMovieCallsCount, 1)
        XCTAssertEqual(mockMovieService.getFavoriteCallsCount, 1)
        
        subject.$favoriteMovies
            .sink { (movies) in
                XCTAssertEqual(movies, Constant.movies)
            }
            .store(in: &cancellables)
        
        subject.$watchedMovies
            .sink { (movies) in
                XCTAssertEqual(movies, Constant.movies)
            }
            .store(in: &cancellables)
        
        subject.$unwatchedMovies
            .sink { (movies) in
                XCTAssertNotEqual(movies, Constant.movies)
            }
            .store(in: &cancellables)
        
        subject.$state
            .sink { (state) in
                XCTAssertEqual(state, MovieListViewModelState.success)
            }
            .store(in: &cancellables)
            
    }
    
    func test_getMovies_givenServiceCallFails_shouldUpdateStateWithError() {
        // given
        mockMovieService.getMovieResult = .failure(MockError.error)
        mockMovieService.getFavoriteResult = .failure(MockError.error)
        
        // when
        subject.getMovies()
        
        // then
        XCTAssertEqual(mockMovieService.getFavoriteCallsCount, 1)
        XCTAssertEqual(mockMovieService.getMovieCallsCount, 1)
        
        subject.$favoriteMovies
            .sink { (movies) in
                XCTAssertEqual(movies, [])
            }
            .store(in: &cancellables)
        
        subject.$watchedMovies
            .sink { (movies) in
                XCTAssertEqual(movies, [])
            }
            .store(in: &cancellables)
        
        subject.$unwatchedMovies
            .sink { (movies) in
                XCTAssertEqual(movies, [])
            }
            .store(in: &cancellables)
        
        subject.$state
            .sink { (state) in
                XCTAssertEqual(state, .error(.fetchMovieError))
            }
            .store(in: &cancellables)
    }
}

// MARK: Helpers

extension MovieListViewModelTests {
    struct Constant {
        static let movies = [
            Movie(backdropPath: "", id: 0, originalLanguage: "en", originalTitle: "Test title", overview: "test overview", popularity: 10, posterPath: "", title: "test title", rating: 5, releaseDate: "01-01-2021", isWatched: true)
        ]
        static let favorites = [
            Favorite(id: 0)
        ]
    }
}
