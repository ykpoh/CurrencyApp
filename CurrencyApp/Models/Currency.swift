//
//  Currency.swift
//  CurrencyApp
//
//  Created by YK Poh on 11/06/2022.
//

import Foundation

struct Currency: Codable, Equatable {
    let symbol: String
    let name: String
    var fullName: String {
        return "\(symbol) - \(name)"
    }
}

func ==(lhs: Currency, rhs: Currency) -> Bool {
    if lhs.symbol != rhs.symbol || lhs.name != rhs.name {
        return false
    }
    
    return true
}
