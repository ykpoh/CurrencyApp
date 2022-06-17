//
//  ConvertedAmountCellTests.swift
//  CurrencyAppTests
//
//  Created by YK Poh on 17/06/2022.
//

import XCTest
@testable import CurrencyApp

class ConvertedAmountCellTests: XCTestCase {
    
    var tableView: UITableView!
    var mockDataSource: MockCellDataSource!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "\(CurrencyViewController.self)") as! CurrencyViewController
        _ = vc.view
        
        tableView = vc.tableView
        mockDataSource = MockCellDataSource()
        tableView.dataSource = mockDataSource
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        tableView = nil
        mockDataSource = nil
        try super.tearDownWithError()
    }
    
    func testCell_Config_SetLabelsToViewModelValue() {
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(ConvertedAmountCell.self)", for: IndexPath(row: 0, section: 0)) as! ConvertedAmountCell
        
        let viewModel = ConvertedAmountViewModel()
        viewModel.convertedAmount.value = "(1 Euro = 141.2469 JPY)"
        viewModel.exchangeRate.value = "JPY 141.25"
        
        cell.configure(viewModel)
        
        XCTAssertEqual(cell.convertedAmountLabel?.text, "(1 Euro = 141.2469 JPY)")
        XCTAssertEqual(cell.exchangeRateLabel?.text, "JPY 141.25")
    }
}
