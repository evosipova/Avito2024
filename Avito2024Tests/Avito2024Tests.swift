//
//  Avito2024Tests.swift
//  Avito2024Tests
//
//  Created by Elizaveta Osipova on 4/14/24.
//

import XCTest
@testable import Avito2024

class Avito2024Tests: XCTestCase {

    func testMediaItemDecodable() {
        let json = """
        {
            "wrapperType": "track",
            "description": "Test track",
            "kind": "song",
            "artistName": "Test Artist",
            "trackName": "Test Song",
            "artistViewUrl": "http://example.com/artist",
            "trackViewUrl": "http://example.com/track",
            "artworkUrl100": "http://example.com/artwork.jpg",
            "trackPrice": 1.99,
            "trackTimeMillis": 300000,
            "currency": "USD"
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        let result = try? decoder.decode(MediaItem.self, from: json)
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.trackName, "Test Song")
        XCTAssertEqual(result?.artistName, "Test Artist")
        XCTAssertEqual(result?.trackPrice, 1.99)
    }

    func testSearchResultDecodable() {
        let json = """
        {
            "results": [
                {
                    "wrapperType": "track",
                    "description": "Test track",
                    "kind": "song",
                    "artistName": "Test Artist",
                    "trackName": "Test Song",
                    "artistViewUrl": "http://example.com/artist",
                    "trackViewUrl": "http://example.com/track",
                    "artworkUrl100": "http://example.com/artwork.jpg",
                    "trackPrice": 1.99,
                    "trackTimeMillis": 300000,
                    "currency": "USD"
                }
            ]
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        let result = try? decoder.decode(SearchResult.self, from: json)
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.results.count, 1)
        XCTAssertEqual(result?.results.first?.trackName, "Test Song")
    }
}
