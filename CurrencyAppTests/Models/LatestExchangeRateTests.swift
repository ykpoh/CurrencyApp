//
//  LatestExchangeRateTests.swift
//  CurrencyAppTests
//
//  Created by YK Poh on 13/06/2022.
//

import XCTest
@testable import CurrencyApp

class LatestExchangeRateTests: XCTestCase {
    
    var sut: LatestExchangeRate!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()
        let data = getJSONData(filename: "LatestExchangeRate")
      
        let decoder = JSONDecoder()
        sut = try! decoder.decode(LatestExchangeRate.self, from: data)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
        try super.tearDownWithError()
    }
    
    func testDecode_Disclaimer() {
        XCTAssertEqual(sut.disclaimer, "Usage subject to terms: https://openexchangerates.org/terms")
    }
    
    func testDecode_License() {
        XCTAssertEqual(sut.license, "https://openexchangerates.org/license")
    }
    
    func testDecode_Timestamp() {
        let date = Date(timeIntervalSince1970: 1654934415)
        XCTAssertEqual(sut.timestamp, date)
    }
    
    func testDecode_Base() {
        XCTAssertEqual(sut.base, "USD")
    }
    
    func testDecode_Rates() {
        XCTAssertFalse(sut.rates!.isEmpty)
        XCTAssertTrue(sut.rates!.contains(where: { key, value in
            key == "AED" && value == 3.6731
        }))
    }

}
