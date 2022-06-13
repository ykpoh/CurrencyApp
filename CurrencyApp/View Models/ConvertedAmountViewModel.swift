//
//  ConvertedAmountViewModel.swift
//  CurrencyApp
//
//  Created by YK Poh on 13/06/2022.
//

import Foundation

public class ConvertedAmountViewModel {
    let exchangeRateText = Box("")
    let convertedAmountText = Box("")
    let exchangeRate: Box<Double?> = Box(nil)
    let convertedAmount: Box<Double?> = Box(nil)
    let currencySymbol = Box("")
    let currencyName = Box("")
}
