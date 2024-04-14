//
//  loadImage.swift
//  Avito2024
//
//  Created by Elizaveta Osipova on 4/14/24.
//

import Foundation
import UIKit

// MARK: - ImageLoader
class ImageLoader {
    func loadImage(urlString: String, completion: @escaping (Result<UIImage, Error>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP Status Code: \(httpResponse.statusCode)"])))
                return
            }

            if let error = error {
                completion(.failure(error))
                return
            }

            if let data = data, let image = UIImage(data: data) {
                completion(.success(image))
            } else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Data or image could not be decoded"])))
            }
        }.resume()
    }
}
