//
//  CurrencyViewModel.swift
//  CurrencyApp
//
//  Created by YK Poh on 12/06/2022.
//

import Foundation

class CurrencyViewModel {
    let amount: Box<Double> = Box(10.00)
    let selectedCurrency: Box<Currency?> = Box(nil)
    let currencies: Box<[Currency]> = Box([])
    let convertedAmounts: Box<[ConvertedAmountViewModel]> = Box([])
    var latestExchangeRate: Box<LatestExchangeRate?> = Box(nil)
    var exchangeRates: Box<[ExchangeRate]> = Box([])
    
    var lastUpdateCurrencyDate: Date? = nil
    var lastUpdateExchangeRateDate: Date? = nil
    
    
    init() {
        if let amount = UserDefaultService.load(key: .amount) as Double? {
            self.amount.value = amount
        }
        
        if let currencies: [Currency] = FileStorageService.load(fileType: .currencies) as [Currency]? {
            self.currencies.value = currencies
        }
        
        selectedCurrency.value = UserDefaultService.load(key: .selectedCurrency) as Currency?
        
        if let exchangeRates = FileStorageService.load(fileType: .exchangeRates) as [ExchangeRate]? {
            self.exchangeRates.value = exchangeRates
            self.convertedAmounts.value = exchangeRates.compactMap({
                convertAmount($0.currency, targetExchangeRate: $0)
            })
        }
        
        getCurrencies()
    }
    
    func getCurrencies() {
        if let lastUpdateCurrencyDate = lastUpdateCurrencyDate,
           Date.now.minutesDifference(date: lastUpdateCurrencyDate) < 30 {
            return
        }
        
        OpenExchangeRatesService.getCurrencies { [weak self] response, error in
            guard let strongSelf = self, let response = response, error == nil else {
                return
            }
            strongSelf.lastUpdateCurrencyDate = Date.now
            strongSelf.currencies.value = response
        }
    }
    
    func getLatestExchangeRates(baseCurrency: Currency) {
        if let lastUpdateExchangeRateDate = lastUpdateExchangeRateDate,
           lastUpdateExchangeRateDate.minutesDifference(date: Date.now) < 30 {
            return
        }
        
        OpenExchangeRatesService.getLatestExchangeRates { [weak self] response, error in
            guard let strongSelf = self, var rates = response?.rates, error == nil else {
                // Error handling
                return
            }
            
            strongSelf.lastUpdateExchangeRateDate = Date.now
            
            strongSelf.latestExchangeRate.value = response
            
            FileStorageService.save(value: response, fileType: .latestExchangeRates)
            
            // Handle case when baseCurrency doesn't exist in rates array
            guard let baseCurrencySymbol = baseCurrency.symbol else {
                return
            }
            
            guard let baseCurrencyToUSDRate = rates.first(where: { (key, value) in
                key == baseCurrency.symbol
            })?.value else {
                // Error handling
                return
            }
            
            // Remove base currency from the rates array
            rates.removeValue(forKey: baseCurrencySymbol)
            
            var exchangeRates = [ExchangeRate]()
            var convertedAmounts = [ConvertedAmountViewModel]()
            
            rates.forEach({ (key, value) in
                let rate = value / baseCurrencyToUSDRate
                let exchangeRate = ExchangeRate(currency: Currency(symbol: key), rate: rate)
                exchangeRates.append(exchangeRate)
                
                let convertedAmount = strongSelf.convertAmount(baseCurrency, targetExchangeRate: exchangeRate)
                convertedAmounts.append(convertedAmount)
            })
            
            strongSelf.exchangeRates.value = exchangeRates
            strongSelf.convertedAmounts.value = convertedAmounts
        }
    }
    
    func updateConvertedAmounts() {
        self.convertedAmounts.value = exchangeRates.value.compactMap({
            convertAmount($0.currency, targetExchangeRate: $0)
        })
    }
    
    private func convertAmount(_ baseCurrency: Currency, targetExchangeRate: ExchangeRate) -> ConvertedAmountViewModel {
        let amount = amount.value * targetExchangeRate.rate
        
        let roundedRate = String(format: "%.4f", targetExchangeRate.rate)
        let roundedAmount = String(format: "%.2f", amount)
        
        let exchangeRateText = "(1 \(baseCurrency.symbol ?? "") = \(roundedRate) \(targetExchangeRate.currency.symbol ?? ""))"
        let convertedAmountText = "\(targetExchangeRate.currency.symbol ?? "") \(roundedAmount)"
        
        let convertedAmountViewModel = ConvertedAmountViewModel()
        convertedAmountViewModel.exchangeRate.value = exchangeRateText
        convertedAmountViewModel.convertedAmount.value = convertedAmountText
        return convertedAmountViewModel
    }
}

extension Date {
    func minutesDifference(date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: self, to: date).minute ?? 0
    }
}
