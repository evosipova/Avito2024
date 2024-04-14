//
//  NetworkService.swift
//  Avito2024
//
//  Created by Elizaveta Osipova on 4/14/24.
//

import Foundation

// MARK: - NetworkService
struct NetworkService {
    func searchMedia(searchTerm: String, entity: String? = nil, limit: Int = 30, completion: @escaping (Result<SearchResult, Error>) -> Void) {
        var components = URLComponents(string: "https://itunes.apple.com/search")
        var queryItems = [URLQueryItem(name: "term", value: searchTerm), URLQueryItem(name: "limit", value: String(limit))]
        if let entity = entity {
            queryItems.append(URLQueryItem(name: "entity", value: entity))
        }
        components?.queryItems = queryItems

        guard let url = components?.url else {
            completion(.failure(NSError(domain: "NetworkServiceError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "NetworkServiceError", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            do {
                let searchResults = try JSONDecoder().decode(SearchResult.self, from: data)
                completion(.success(searchResults))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
