//
//  Currency.swift
//  CurrencyApp
//
//  Created by YK Poh on 11/06/2022.
//

import Foundation

struct Currency: Codable {
    let symbol: String?
    let name: String?
    var fullName: String? {
        guard let symbol = symbol, let name = name else {
            return nil
        }
        return "\(symbol) - \(name)"
    }
    
    init(symbol: String, name: String? = nil) {
        self.symbol = symbol
        self.name = name
    }
}

extension Currency: Equatable {
  static func == (lhs: Currency, rhs: Currency) -> Bool {
      if lhs.symbol != rhs.symbol || lhs.name != rhs.name {
          return false
      }
      
      return true
  }
}
