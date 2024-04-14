//
//  MediaItem.swift
//  Avito2024
//
//  Created by Elizaveta Osipova on 4/14/24.
//

import Foundation

// MARK: - SearchResult
struct SearchResult: Codable {
    let results: [MediaItem]
}

// MARK: - MediaItem Model
struct MediaItem: Codable {
    let wrapperType: String?
    let description: String?
    let kind: String?
    let artistName: String?
    let trackName: String?
    let artistViewUrl: String?
    let trackViewUrl: String?
    let artworkUrl100: String?
    let trackPrice: Double?
    let trackTimeMillis: Int?
    let currency: String?
}
