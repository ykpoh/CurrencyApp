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
