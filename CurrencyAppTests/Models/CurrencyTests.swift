//
//  CurrencyTests.swift
//  CurrencyAppTests
//
//  Created by YK Poh on 11/06/2022.
//

import XCTest
@testable import CurrencyApp

class CurrencyTests: XCTestCase {
    
    var sut: [Currency]!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()
        let data = getJSONData(filename: "Currencies")
      
        let decoder = JSONDecoder()
        let dictionaries = try! decoder.decode([String:String].self, from: data)
        sut = dictionaries.compactMap({ key, value in
            Currency(symbol: key, name: value)
        })
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
        try super.tearDownWithError()
    }
    
    func testDecode_ReturnNotNilAndEmptyArray() {
        XCTAssertNotNil(sut)
        XCTAssertFalse(sut.isEmpty)
        let currency = Currency(symbol: "AED", name: "United Arab Emirates Dirham")
        XCTAssertTrue(sut.contains(where: { $0 == currency}))
    }

}
