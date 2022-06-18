//
//  ConvertedAmountViewModel.swift
//  CurrencyApp
//
//  Created by YK Poh on 13/06/2022.
//

import Foundation

class ConvertedAmountViewModel {
    let exchangeRate: Box<String> = Box("")
    let convertedAmount: Box<String> = Box("")
    var exchangeRateModel: ExchangeRate? = nil
}

extension ConvertedAmountViewModel: Equatable {
    static func == (lhs: ConvertedAmountViewModel, rhs: ConvertedAmountViewModel) -> Bool {
        lhs.exchangeRateModel == rhs.exchangeRateModel
    }
}
