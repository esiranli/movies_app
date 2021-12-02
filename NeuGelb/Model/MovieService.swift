//
//  MovieService.swift
//  NeuGelb
//
//  Created by EMRE on 30.11.2021.
//

import Foundation
import Combine

protocol MovieServiceProtocol {
    func fetchMovies() -> AnyPublisher<Response<Movie>, Error>
    func fetchFavorites() -> AnyPublisher<Response<Favorite>, Error>
}


class MovieService: MovieServiceProtocol  {
    
    struct ApiConstants {
        static let apiKey = "135797531"
        static let hostUrl = "r9q6m.mocklab.io"
    }
    
    func fetchMovies() -> AnyPublisher<Response<Movie>, Error> {
        self.fetch(path: "/list")
    }
    
    func fetchFavorites() -> AnyPublisher<Response<Favorite>, Error>{
        self.fetch(path: "/favorites")
    }
    
    private func fetch<T: Decodable>(path: String) -> AnyPublisher<Response<T>, Error> {
        return URLSession.shared
            .dataTaskPublisher(for: getUrlRequest(path: path)!)
            .tryMap({ (element) -> Data in
                guard let httpResponse = element.response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return element.data
        })
        .decode(type: Response<T>.self, decoder: self.decoder)
        .eraseToAnyPublisher()
    }
    
    private func getUrlRequest(path: String) -> URLRequest? {
        var components = URLComponents()
        components.scheme = "http"
        components.host = ApiConstants.hostUrl
        components.path = "/movies\(path)"
        components.queryItems = [URLQueryItem(name: "api_key", value: ApiConstants.apiKey)]
    
        guard let url = components.url else {
            return nil
        }
        print("url is \(url.absoluteString)")
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        return urlRequest
    }
    
    private lazy var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
}
