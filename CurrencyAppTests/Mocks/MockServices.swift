//
//  MockServices.swift
//  CurrencyAppTests
//
//  Created by YK Poh on 17/06/2022.
//

import Foundation
@testable import CurrencyApp

class MockUserDefaultService: UserDefaultServiceProtocol {
    static var dictionary = [UserDefaultServiceKey.RawValue: Bool]()
    static var loadValue: Any? = nil
    
    static func encodeAndSave<T>(key: UserDefaultServiceKey, value: T) where T: Codable {
        dictionary[key.rawValue] = true
    }
    
    static func save<T>(key: UserDefaultServiceKey, value: T) where T: Codable {
        dictionary[key.rawValue] = true
    }
    
    static func load<T>(key: UserDefaultServiceKey) -> T? where T: Codable {
        dictionary[key.rawValue] = false
        return loadValue as? T
    }
    
    static func clear() {
        dictionary = [UserDefaultServiceKey.RawValue: Bool]()
        loadValue = nil
    }
}

class MockFileStorageService: FileStorageServiceProtocol {
    static var dictionary = [FileStorageServiceType.RawValue: Any]()
    
    static func save<T>(value: T, fileType: FileStorageServiceType) where T: Codable {
        dictionary[fileType.rawValue] = value
    }
    
    static func load<T>(fileType: FileStorageServiceType) -> T? where T: Codable {
        return dictionary[fileType.rawValue] as? T
    }
    
    static func clear() {
        dictionary = [FileStorageServiceType.RawValue: Any]()
    }
}

class MockOpenExchangeService: OpenExchangeRatesProtocol {
    static var currencies: [Currency]?
    static var getCurrenciesError: OpenExchangeRatesError?
    static var latestExchangeRate: LatestExchangeRate?
    static var getLatestExchangeRateError: OpenExchangeRatesError?
    
    static func getCurrencies(completion: @escaping ([Currency]?, OpenExchangeRatesError?) -> ()) {
        completion(currencies, getCurrenciesError)
    }
    
    static func getLatestExchangeRates(completion: @escaping (LatestExchangeRate?, OpenExchangeRatesError?) -> ()) {
        completion(latestExchangeRate, getLatestExchangeRateError)
    }
    
    static func clear() {
        currencies = nil
        getCurrenciesError = nil
        latestExchangeRate = nil
        getLatestExchangeRateError = nil
    }
}
