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
}

extension ConvertedAmountViewModel: Equatable {
  static func == (lhs: ConvertedAmountViewModel, rhs: ConvertedAmountViewModel) -> Bool {
      if lhs.exchangeRate.value != rhs.exchangeRate.value || lhs.convertedAmount.value != rhs.convertedAmount.value {
          return false
      }
      
      return true
  }
}
