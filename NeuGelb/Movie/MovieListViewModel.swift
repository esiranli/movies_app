//
//  MovieViewModel.swift
//  NeuGelb
//
//  Created by EMRE on 30.11.2021.
//

import Foundation
import Combine

enum MovieListViewModelError: Error {
    case fetchMovieError
//    case fetchFavoritesError
}

enum MovieListViewModelState: Equatable {
    case loading, error(MovieListViewModelError), success
}

final class MovieListViewModel: ObservableObject {
    
    @Published private(set) var favoriteMovies = [Movie]()
    @Published private(set) var watchedMovies = [Movie]()
    @Published private(set) var unwatchedMovies = [Movie]()
//    @Published private(set) var favorites = [Favorite]()
//    @Published private(set) var movies = [Movie]()
    
    @Published private(set) var state: MovieListViewModelState = .loading
    
    private var service: MovieServiceProtocol!
    private var cancellable: AnyCancellable?
    
    init(service: MovieServiceProtocol = MovieService()) {
        self.service = service
    }
    
    func getMovies() {
        state = .loading
        
        self.cancellable = Publishers.Zip(
            service.fetchMovies(),
            service.fetchFavorites()
        )
        .sink(receiveCompletion: { [weak self] completion in
            switch completion {
            case .failure:
                self?.state = .error(.fetchMovieError)
                break
            case .finished:
                self?.state = .success
            }
        }, receiveValue: { [weak self] movieItems, favorites in
            print("received movies \(movieItems)")
            print("received favorites \(favorites)")
            let movies = movieItems.results
            let favorites = favorites.results
            
            self?.favoriteMovies = movies.filter { movie in
                favorites.contains { favorite in
                    movie.id == favorite.id
                }
            }.sorted(by: >)
            self?.watchedMovies = movies.filter { $0.isWatched }.sorted(by: >)
            self?.unwatchedMovies = movies.filter { !$0.isWatched }.sorted(by: >)
        })
    }
}
