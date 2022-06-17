//
//  CurrencyViewModelTests.swift
//  CurrencyAppTests
//
//  Created by YK Poh on 17/06/2022.
//

import XCTest
@testable import CurrencyApp

class CurrencyViewModelTests: XCTestCase {
    
    var sut: CurrencyViewModel!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()
        sut = CurrencyViewModel()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
        try super.tearDownWithError()
    }
    
}
