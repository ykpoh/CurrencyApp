//
//  XCTestCase+Helpers.swift
//  CurrencyAppTests
//
//  Created by YK Poh on 13/06/2022.
//

import Foundation
import XCTest

extension XCTestCase {
    func getJSONData(filename: String) -> Data {
        let bundle = Bundle(for: type(of: self))
        let url = bundle.url(forResource: filename, withExtension: "json")!
        return try! Data(contentsOf: url)
    }
}
