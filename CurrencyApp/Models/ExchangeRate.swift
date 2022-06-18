//
//  ExchangeRate.swift
//  CurrencyApp
//
//  Created by YK Poh on 15/06/2022.
//

import Foundation

struct ExchangeRate: Codable {
    let currency: Currency
    let rate: Double
}

extension ExchangeRate: Equatable {
    static func == (lhs: ExchangeRate, rhs: ExchangeRate) -> Bool {
        if lhs.currency != rhs.currency || lhs.rate != rhs.rate {
            return false
        }
        
        return true
    }
}
