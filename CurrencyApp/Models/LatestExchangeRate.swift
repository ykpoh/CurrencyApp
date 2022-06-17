//
//  LatestExchangeRate.swift
//  CurrencyApp
//
//  Created by YK Poh on 13/06/2022.
//

import Foundation

struct LatestExchangeRate: Codable {
    let disclaimer: String?
    let license: String?
    let timestamp: Date?
    let base: String?
    let rates: [String: Double]?
    
    enum CodingKeys: String, CodingKey {
      case disclaimer, license, timestamp, base, rates
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        disclaimer = try container.decodeIfPresent(String.self, forKey: .disclaimer)
        license = try container.decodeIfPresent(String.self, forKey: .license)
        base = try container.decodeIfPresent(String.self, forKey: .base)
        rates = try container.decodeIfPresent([String: Double].self, forKey: .rates)
        if let timestampTimeInterval = try container.decodeIfPresent(TimeInterval.self, forKey: .timestamp) {
            timestamp = Date(timeIntervalSince1970: timestampTimeInterval)
        } else {
            timestamp = nil
        }
    }
}
