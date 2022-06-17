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
    var latestExchangeRateModel: Box<LatestExchangeRate?> = Box(nil)
    
    weak var timer: Timer?
    
    init() {
        if let amount = UserDefaultService.load(key: .amount) as Double? {
            self.amount.value = amount
        }
        
        if let currencies: [Currency] = FileStorageService.load(fileType: .currencies) as [Currency]? {
            self.currencies.value = currencies
        }
        
        selectedCurrency.value = UserDefaultService.load(key: .selectedCurrency) as Currency?
        
        if let latestExchangeRateModel = FileStorageService.load(fileType: .latestExchangeRates) as LatestExchangeRate? {
            self.latestExchangeRateModel.value = latestExchangeRateModel
            updateConvertedAmounts()
        }
        
        getCurrencies()
        getLatestExchangeRates()
    }
    
    deinit {
        stopTimer()
    }
    
    func getCurrencies() {
        OpenExchangeRatesService.getCurrencies { [weak self] response, error in
            guard let strongSelf = self, let response = response, error == nil else {
                return
            }
            strongSelf.currencies.value = response
        }
    }
    
    @objc func getLatestExchangeRates() {
        // Reset and start a timer to call exchange rate API every 30 minutes
        startTimer()
        
        OpenExchangeRatesService.getLatestExchangeRates { [weak self] response, error in
            guard let strongSelf = self, let response = response, error == nil else {
                // Error handling
                return
            }
            
            strongSelf.latestExchangeRateModel.value = response
            
            strongSelf.updateConvertedAmounts()
        }
    }
    
    func updateConvertedAmounts() {
        guard let baseCurrency = selectedCurrency.value, let baseCurrencySymbol = baseCurrency.symbol else { return }
        guard var latestExchangeRates = latestExchangeRateModel.value?.rates else { return }
        
        guard let baseCurrencyToUSDRate = latestExchangeRates.first(where: { (key, value) in
            key == baseCurrency.symbol
        })?.value else {
            // Error handling
            return
        }
        
        // Remove base currency from the rates array
        latestExchangeRates.removeValue(forKey: baseCurrencySymbol)
        
        var convertedAmounts = [ConvertedAmountViewModel]()
        
        latestExchangeRates.forEach({ (key, value) in
            let rate = value / baseCurrencyToUSDRate
            let exchangeRate = ExchangeRate(currency: Currency(symbol: key), rate: rate)

            let convertedAmount = convertAmount(baseCurrency, targetExchangeRate: exchangeRate)
            convertedAmounts.append(convertedAmount)
        })
        
        self.convertedAmounts.value = convertedAmounts
    }
    
    private func startTimer() {
        stopTimer()
        timer = nil
        timer = Timer.scheduledTimer(timeInterval: 1800, target: self, selector: #selector(getLatestExchangeRates), userInfo: nil, repeats: true)
    }
    
    private func stopTimer() {
        timer?.invalidate()
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
