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
    var mockUserDefaultServiceType: MockUserDefaultService.Type!
    var mockFileStorageServiceType: MockFileStorageService.Type!
    var mockOpenExchangeServiceType: MockOpenExchangeService.Type!
    var mockTimerType: Timer.Type!
    
    let brazilCurrency = Currency(symbol: "BRL", name: "Brazilian Real")
    let thaiCurrency = Currency(symbol: "THB", name: "Thai Baht")
    let malaysiaCurrency = Currency(symbol: "MYR", name: "Malaysian Ringgit")
    let vefCurrency = Currency(symbol: "VEF", name: "Venezuelan Bolívar Fuerte (Old)")

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()
        
        mockUserDefaultServiceType = MockUserDefaultService.self
        mockFileStorageServiceType = MockFileStorageService.self
        mockOpenExchangeServiceType = MockOpenExchangeService.self
        mockTimerType = MockTimer.self
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        mockUserDefaultServiceType.clear()
        mockFileStorageServiceType.clear()
        mockOpenExchangeServiceType.clear()
        MockTimer.clear()
        mockUserDefaultServiceType = nil
        mockFileStorageServiceType = nil
        mockOpenExchangeServiceType = nil
        mockTimerType = nil
        sut = nil
        try super.tearDownWithError()
    }
    
    func testInit_LoadStorage_AssignToAmount() {
        // given
        mockUserDefaultServiceType.loadValue = 100.0
        
        // when
        initializeViewModel()
        
        // then
        XCTAssertFalse(mockUserDefaultServiceType.dictionary[UserDefaultServiceKey.amount.rawValue] ?? true)
        XCTAssertEqual(sut.amount.value, 100.0)
    }
    
    func testInit_LoadStorage_AssignToCurrencies() {
        // given
        let array = [
            brazilCurrency,
            thaiCurrency,
            malaysiaCurrency
        ]
        mockFileStorageServiceType.save(value: array, fileType: .currencies)
        
        // when
        initializeViewModel()
        
        // then
        XCTAssertEqual(mockFileStorageServiceType.dictionary[FileStorageServiceType.currencies.rawValue] as? [Currency], array)
        XCTAssertEqual(sut.currencies.value, array)
    }
    
    func testInit_LoadStorage_AssignToSelectedCurrency() {
        // given
        mockUserDefaultServiceType.loadValue = brazilCurrency
        
        // when
        initializeViewModel()
        
        // then
        XCTAssertFalse(mockUserDefaultServiceType.dictionary[UserDefaultServiceKey.selectedCurrency.rawValue] ?? true)
        XCTAssertEqual(sut.selectedCurrency.value, brazilCurrency)
    }
    
    func testInit_LoadLatestExchangeRateFromFileStorage_() {
        // given
        let model = getLatestExchangeRateFromJSON()
        mockFileStorageServiceType.save(value: model, fileType: .latestExchangeRates)
        
        initializeViewModel()
        
        XCTAssertEqual(mockFileStorageServiceType.dictionary[FileStorageServiceType.latestExchangeRates.rawValue] as? LatestExchangeRate, model)
        XCTAssertEqual(sut.latestExchangeRateModel.value, model)
    }
    
    func testInit_UpdateConvertedAmounts_ReturnsConvertedAmounts() {
        // given
        mockUserDefaultServiceType.loadValue = brazilCurrency
        
        let array = [
            brazilCurrency,
            thaiCurrency,
            malaysiaCurrency
        ]
        mockFileStorageServiceType.save(value: array, fileType: .currencies)
        
        let model = getLatestExchangeRateFromJSON()
        mockFileStorageServiceType.save(value: model, fileType: .latestExchangeRates)
        
        // when
        initializeViewModel()
        
        // then
        XCTAssertFalse(sut.convertedAmounts.value.isEmpty)
        XCTAssertFalse(sut.convertedAmounts.value.contains(where: { $0.exchangeRateModel?.currency == brazilCurrency
        }))
        XCTAssertEqual(model.rates!.count - 1, sut.convertedAmounts.value.count)
    }
    
    func testInit_GetCurrencies_ReturnsCurrencies() {
        // given
        let currencyModel = getCurrenciesFromJSON()
        mockOpenExchangeServiceType.currencies = currencyModel
        
        // when
        initializeViewModel()
        
        // then
        XCTAssertFalse(sut.currencies.value.isEmpty)
        let sortedCurrencyModel = currencyModel.sorted(by: {$0.symbol ?? "" < $1.symbol ?? ""})
        XCTAssertEqual(sut.currencies.value, sortedCurrencyModel)
    }
    
    func testInit_GetLatestExchangeRates_ReturnsLatestExchangeRate() {
        // given
        let latestExchangeRatesModel = getLatestExchangeRateFromJSON()
        mockOpenExchangeServiceType.latestExchangeRate = latestExchangeRatesModel
        
        // when
        initializeViewModel()
        
        // then
        XCTAssertNotNil(sut.latestExchangeRateModel.value)
        XCTAssertEqual(sut.latestExchangeRateModel.value, latestExchangeRatesModel)
    }
    
    func testInit_GetLatestExchangeRates_UpdateConvertedAmounts() {
        // given
        mockUserDefaultServiceType.loadValue = brazilCurrency
        let latestExchangeRatesModel = getLatestExchangeRateFromJSON()
        mockOpenExchangeServiceType.latestExchangeRate = latestExchangeRatesModel
        
        // when
        initializeViewModel()
        
        // then
        XCTAssertFalse(sut.convertedAmounts.value.isEmpty)
        XCTAssertFalse(sut.convertedAmounts.value.contains(where: { $0.exchangeRateModel?.currency == brazilCurrency
        }))
        XCTAssertEqual(latestExchangeRatesModel.rates!.count - 1, sut.convertedAmounts.value.count)
    }
    
    func testStartTimer_WhenGetLatestExchangeRates_CallGetLatestExchangeRates() {
        // given
        mockUserDefaultServiceType.loadValue = brazilCurrency
        let latestExchangeRatesModel = getLatestExchangeRateFromJSON()
        mockOpenExchangeServiceType.latestExchangeRate = latestExchangeRatesModel
        
        initializeViewModel()
        
        XCTAssertNotNil(sut.latestExchangeRateModel.value)
        XCTAssertEqual(sut.latestExchangeRateModel.value, latestExchangeRatesModel)
        
        let updatedLatestExchangeRatesModel = getLatestExchangeRateFromJSON(fileName: "UpdatedLatestExchangeRate")
        mockOpenExchangeServiceType.latestExchangeRate = updatedLatestExchangeRatesModel
        
        // when
        MockTimer.currentTimer.fire()
        
        // then
        XCTAssertNotEqual(sut.latestExchangeRateModel.value, latestExchangeRatesModel)
        XCTAssertEqual(sut.latestExchangeRateModel.value, updatedLatestExchangeRatesModel)
    }
    
    func testConvertAmount_ReturnsConvertedAmountViewModel() {
        // given
        initializeViewModel()
        let amount = 150.55
        sut.amount.value = amount
        let exchangeRateModel = getLatestExchangeRateFromJSON()
        let australianDollarRateModel = exchangeRateModel.rates?.first(where: {  $0.key == "AUD"
        })
        let thaiBahtRateModel = exchangeRateModel.rates?.first(where: {  $0.key == "THB"
        })
        let ausToTHBRate = thaiBahtRateModel!.value / australianDollarRateModel!.value
        
        let thaiBahtExchangeRateModel = ExchangeRate(currency: Currency(symbol: thaiBahtRateModel!.key), rate: ausToTHBRate)
        
        // when
        let viewModel = sut.convertAmount(Currency(symbol: australianDollarRateModel!.key), targetExchangeRate: thaiBahtExchangeRateModel)
    
        // then
        XCTAssertEqual(viewModel.exchangeRate.value, "(1 AUD = 24.4768 THB)")
        XCTAssertEqual(viewModel.convertedAmount.value, "THB 3684.99")
        XCTAssertEqual(viewModel.exchangeRateModel, thaiBahtExchangeRateModel)
    }
    
    func testEmptyURL_GetCurrencies_ReturnsErrorMessage() {
        let message = "Failed request from OpenExchangeRates: error_message"
        mockOpenExchangeServiceType.getCurrenciesError = .emptyURL(message: message)
        
        initializeViewModel()
        
        XCTAssertNotNil(sut.errorMessage.value)
        XCTAssertEqual(sut.errorMessage.value, message)
    }
    
    func testInvalidResponse_GetLatestExchangeRates_ReturnsErrorMessage() {
        let message = "Failed request from OpenExchangeRates: error_message"
        mockOpenExchangeServiceType.getLatestExchangeRateError = .invalidResponse(message: message)
        
        initializeViewModel()
        
        XCTAssertNotNil(sut.errorMessage.value)
        XCTAssertEqual(sut.errorMessage.value, message)
    }
    
    func testUpdateConvertedAmounts_GivenSelectedCurrencyNotExistedInExchangeRates() {
        // given
        initializeViewModel()
        sut.selectedCurrency.value = vefCurrency
        sut.latestExchangeRateModel.value = getLatestExchangeRateFromJSON()
        
        // when
        sut.updateConvertedAmounts()
        
        // then
        XCTAssertNotNil(sut.errorMessage.value)
        XCTAssertEqual(sut.errorMessage.value, "Selected currency doesn't have any exchange rate data. Please select other currencies and try again!")
        XCTAssertTrue(sut.convertedAmounts.value.isEmpty)
    }
    
    func testDeinit_InvalidateTimerAndSetTimerToNil() {
        // given
        initializeViewModel()
        XCTAssertNotNil(MockTimer.currentTimer)
        XCTAssertNotNil(MockTimer.currentTimer.target)
        XCTAssertNotNil(MockTimer.currentTimer.selector)
        
        // when
        MockTimer.clear()
        sut = nil
        
        // then
        XCTAssertNil(MockTimer.currentTimer)
    }
    
    private func initializeViewModel() {
        sut = CurrencyViewModel(
            fileStorageServiceType: mockFileStorageServiceType,
            userDefaultServiceType: mockUserDefaultServiceType,
            openExchangeRatesServiceType: mockOpenExchangeServiceType,
            timerType: mockTimerType
        )
    }
    
    private func getLatestExchangeRateFromJSON(fileName: String = "LatestExchangeRate") -> LatestExchangeRate {
        let data = getJSONData(filename: fileName)
        let decoder = JSONDecoder()
        return try! decoder.decode(LatestExchangeRate.self, from: data)
    }
    
    private func getCurrenciesFromJSON() -> [Currency] {
        let data = getJSONData(filename: "Currencies")
        let decoder = JSONDecoder()
        let dictionaries = try! decoder.decode([String:String].self, from: data)
        return dictionaries.compactMap({ key, value in
            Currency(symbol: key, name: value) })
    }
}
