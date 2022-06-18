//
//  MockViewModels.swift
//  CurrencyAppTests
//
//  Created by YK Poh on 17/06/2022.
//

import Foundation
@testable import CurrencyApp

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
