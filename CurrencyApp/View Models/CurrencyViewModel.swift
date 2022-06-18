//
//  CurrencyViewModel.swift
//  CurrencyApp
//
//  Created by YK Poh on 12/06/2022.
//

import Foundation

protocol CurrencyViewModelProtocol {
    var title: Box<String> { get }
    var amount: Box<Double> { get }
    var selectedCurrency: Box<Currency?> { get }
    var currencies: Box<[Currency]> { get }
    var convertedAmounts: Box<[ConvertedAmountViewModel]> { get }
    var latestExchangeRateModel: Box<LatestExchangeRate?> { get }
    func getCurrencies()
    func getLatestExchangeRates()
    func updateConvertedAmounts()
}

class CurrencyViewModel: CurrencyViewModelProtocol {
    let title: Box<String> = Box("Convert")
    let amount: Box<Double> = Box(10.00)
    let selectedCurrency: Box<Currency?> = Box(nil)
    let currencies: Box<[Currency]> = Box([])
    let convertedAmounts: Box<[ConvertedAmountViewModel]> = Box([])
    var latestExchangeRateModel: Box<LatestExchangeRate?> = Box(nil)
    
    weak var timer: Timer?
    var timerType: Timer.Type
    var fileStorageServiceType: FileStorageServiceProtocol.Type
    var userDefaultServiceType: UserDefaultServiceProtocol.Type
    var openExchangeRatesServiceType: OpenExchangeRatesProtocol.Type
    
    init(fileStorageServiceType: FileStorageServiceProtocol.Type = FileStorageService.self,
         userDefaultServiceType: UserDefaultServiceProtocol.Type = UserDefaultService.self,
         openExchangeRatesServiceType: OpenExchangeRatesProtocol.Type = OpenExchangeRatesService.self,
         timerType: Timer.Type = Timer.self) {
        self.timerType = timerType
        self.fileStorageServiceType = fileStorageServiceType
        self.userDefaultServiceType = userDefaultServiceType
        self.openExchangeRatesServiceType = openExchangeRatesServiceType
        
        if let amount = userDefaultServiceType.load(key: .amount) as Double? {
            self.amount.value = amount
        }
        
        if let currencies: [Currency] = fileStorageServiceType.load(fileType: .currencies) as [Currency]? {
            self.currencies.value = currencies
        }
        
        selectedCurrency.value = userDefaultServiceType.load(key: .selectedCurrency) as Currency?
        
        if let latestExchangeRateModel = fileStorageServiceType.load(fileType: .latestExchangeRates) as LatestExchangeRate? {
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
        openExchangeRatesServiceType.getCurrencies { [weak self] response, error in
            guard let strongSelf = self, let response = response, error == nil else {
                return
            }
            strongSelf.currencies.value = response.sorted(by: {$0.symbol ?? "" < $1.symbol ?? ""})
        }
    }
    
    @objc func getLatestExchangeRates() {
        // Reset and start a timer to call exchange rate API every 30 minutes
        startTimer()
        
        openExchangeRatesServiceType.getLatestExchangeRates { [weak self] response, error in
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
        
        let sortedLatestExchangeRates = latestExchangeRates.sorted(by: {$0.key < $1.key})
        
        var convertedAmounts = [ConvertedAmountViewModel]()
        
        sortedLatestExchangeRates.forEach({ (key, value) in
            let rate = value / baseCurrencyToUSDRate
            let exchangeRate = ExchangeRate(currency: Currency(symbol: key), rate: rate)

            let convertedAmount = convertAmount(baseCurrency, targetExchangeRate: exchangeRate)
            convertedAmounts.append(convertedAmount)
        })
        
        self.convertedAmounts.value = convertedAmounts
    }
    
    private func startTimer() {
        stopTimer()
        timer = timerType.scheduledTimer(timeInterval: 1800, target: self, selector: #selector(getLatestExchangeRates), userInfo: nil, repeats: true)
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    internal func convertAmount(_ baseCurrency: Currency, targetExchangeRate: ExchangeRate) -> ConvertedAmountViewModel {
        let amount = amount.value * targetExchangeRate.rate
        
        let roundedRate = String(format: "%.4f", targetExchangeRate.rate)
        let roundedAmount = String(format: "%.2f", amount)
        
        let exchangeRateText = "(1 \(baseCurrency.symbol ?? "") = \(roundedRate) \(targetExchangeRate.currency.symbol ?? ""))"
        let convertedAmountText = "\(targetExchangeRate.currency.symbol ?? "") \(roundedAmount)"
        
        let convertedAmountViewModel = ConvertedAmountViewModel()
        convertedAmountViewModel.exchangeRate.value = exchangeRateText
        convertedAmountViewModel.convertedAmount.value = convertedAmountText
        convertedAmountViewModel.exchangeRateModel = targetExchangeRate
        return convertedAmountViewModel
    }
}
