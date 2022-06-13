//
//  CurrencyViewModel.swift
//  CurrencyApp
//
//  Created by YK Poh on 12/06/2022.
//

import Foundation

public class CurrencyViewModel {
    let amount: Box<Decimal> = Box(0.00)
    let selectedCurrency: Box<Currency?> = Box(nil)
    let currencies = Box([Currency]())
    let convertedAmounts = Box([ConvertedAmountViewModel]())
    
    init() {
        OpenExchangeRatesService.getCurrencies { [weak self] response, error in
            guard let strongSelf = self, let response = response, error == nil else {
                return
            }
            strongSelf.currencies.value = response
        }
    }
    
    func getConvertedAmount() {
        
    }
}
