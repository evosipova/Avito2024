//
//  Avito2024UITests.swift
//  Avito2024UITests
//
//  Created by Elizaveta Osipova on 4/14/24.
//

import XCTest

final class Avito2024UITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testSearchTextFieldExistence() {
        let searchTextField = app.textFields["Search..."]
        XCTAssertTrue(searchTextField.exists)
    }
}
