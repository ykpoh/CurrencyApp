//
//  CurrencyViewControllerTests.swift
//  CurrencyAppTests
//
//  Created by YK Poh on 17/06/2022.
//

import XCTest
@testable import CurrencyApp

class CurrencyViewControllerTests: XCTestCase {
    
    var sut: CurrencyViewController!
    var mockUserDefaultService: MockUserDefaultService.Type!
    var mockViewModel: MockCurrencyViewModel!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()
        sut = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "\(CurrencyViewController.self)") as? CurrencyViewController
        mockUserDefaultService = MockUserDefaultService.self
        sut.userDefaultService = mockUserDefaultService
        mockViewModel = MockCurrencyViewModel()
        sut.viewModel = mockViewModel
        _ = sut.view
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        mockUserDefaultService = nil
        mockViewModel = nil
        sut = nil
        try super.tearDownWithError()
    }
    
    func testInit_TableViewNotNil() {
        XCTAssertNotNil(sut.tableView)
    }
    
    func testInit_Title() {
        XCTAssertEqual(sut.title, "Test Title")
    }
    
    func testInit_PickerViewNotNill() {
        XCTAssertNotNil(sut.pickerView)
    }
    
    func testTableViewDataSource_ViewDidLoad_SetsTableViewDataSource() {
        XCTAssertNotNil(sut.tableView.dataSource)
        XCTAssertTrue(sut.tableView.dataSource is CurrencyViewController)
    }
    
    func testPickerViewDataSource_ViewDidLoad_SetsPickerViewDataSource() {
        XCTAssertNotNil(sut.pickerView.dataSource)
        XCTAssertTrue(sut.pickerView.dataSource is CurrencyViewController)
    }
    
    func testTableViewDelegate_ViewDidLoad_SetsTableViewDelegate() {
        XCTAssertNotNil(sut.tableView.delegate)
        XCTAssertTrue(sut.tableView.delegate is CurrencyViewController)
    }
    
    func testPickerViewDelegate_ViewDidLoad_SetsPickerViewDelegate() {
        XCTAssertNotNil(sut.pickerView.delegate)
        XCTAssertTrue(sut.pickerView.delegate is CurrencyViewController)
    }
    
    func testCurrencyTextField_InputViewIsPickerView() {
        XCTAssertNotNil(sut.currencyTextField.inputView)
        XCTAssertTrue(sut.currencyTextField.inputView is UIPickerView)
        XCTAssertEqual(sut.currencyTextField.inputView, sut.pickerView)
    }
    
    func testInit_LoadFirstTime_AmountSubsriber() {
        XCTAssertNotNil(mockUserDefaultService.dictionary[UserDefaultServiceKey.amount.rawValue])
        XCTAssertFalse(sut.isLoadingFirstTime)
        XCTAssertEqual(sut.amountTextField.text, "1.0")
    }
    
    func testAmount_LoadMoreThanOnce_CallUpdateConvertedAmount() {
        // when
        mockViewModel.amount.value = 500
        
        // then
        XCTAssertNotNil(mockUserDefaultService.dictionary[UserDefaultServiceKey.amount.rawValue])
        XCTAssertTrue(mockViewModel.updateConvertedAmountsCalled)
    }
    
    func testInit_SelectedCurrencyIsNil() {
        XCTAssertNil(mockUserDefaultService.dictionary[UserDefaultServiceKey.selectedCurrency.rawValue])
        XCTAssertFalse(mockViewModel.updateConvertedAmountsCalled)
        XCTAssertEqual(sut.currencyTextField.text, "")
    }
    
    func testSelectedCurrency_WhenNotNil() {
        // given
        let currency = Currency(symbol: "BAM", name: "Bosnia-Herzegovina Convertible Mark")
        
        // when
        mockViewModel.selectedCurrency.value = currency
        
        // then
        XCTAssertNotNil(mockUserDefaultService.dictionary[UserDefaultServiceKey.selectedCurrency.rawValue])
        XCTAssertTrue(mockViewModel.updateConvertedAmountsCalled)
        XCTAssertEqual(sut.currencyTextField.text, currency.fullName)
    }
    
    func testTableView_WhenUpdateConvertedAmounts() {
        // given
        let exampleA = ConvertedAmountViewModel()
        exampleA.convertedAmount.value = "USD 105.00"
        exampleA.exchangeRate.value = "AUD 1.00 = USD 0.7000"
        
        // when
        mockViewModel.convertedAmounts.value = [
            exampleA,
            ConvertedAmountViewModel(),
            ConvertedAmountViewModel()
        ]
        
        // then
        XCTAssertEqual(sut.tableView.numberOfRows(inSection: 0), 3)
        let cellQueried = sut.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ConvertedAmountCell
        XCTAssertEqual(cellQueried?.viewModel, exampleA)
    }
    
    class MockUserDefaultService: UserDefaultServiceProtocol {
        static var dictionary = [UserDefaultServiceKey.RawValue: Bool]()
        static var loadCalled = false
        
        static func encodeAndSave<T>(key: UserDefaultServiceKey, value: T) where T: Codable {
            dictionary[key.rawValue] = true
        }
        
        static func save<T>(key: UserDefaultServiceKey, value: T) where T: Codable {
            dictionary[key.rawValue] = true
        }
        
        static func load<T>(key: UserDefaultServiceKey) -> T? where T: Codable {
            loadCalled = true
            return true as? T
        }
    }
    
    class MockFileStorageService: FileStorageServiceProtocol {
        static var dictionary = [FileStorageServiceType.RawValue: Bool]()
        static var loadCalled = false
        
        static func save<T>(value: T, fileType: FileStorageServiceType) where T: Codable {
            dictionary[fileType.rawValue] = true
        }
        
        static func load<T>(fileType: FileStorageServiceType) -> T? where T: Codable {
            loadCalled = true
            return true as? T
        }
    }

    class MockCurrencyViewModel: CurrencyViewModelProtocol {
        var getCurrenciesCalled = false
        var updateConvertedAmountsCalled = false
        
        let title: Box<String> = Box("Test Title")
        let amount: Box<Double> = Box(1)
        let selectedCurrency: Box<Currency?> = Box(nil)
        let currencies: Box<[Currency]> = Box([])
        let convertedAmounts: Box<[ConvertedAmountViewModel]> = Box([])
        var latestExchangeRateModel: Box<LatestExchangeRate?> = Box(nil)

        func getCurrencies() {
            getCurrenciesCalled = true
        }
        
        func getLatestExchangeRates() {
            
        }
        
        func updateConvertedAmounts() {
            updateConvertedAmountsCalled = true
        }
    }
}
