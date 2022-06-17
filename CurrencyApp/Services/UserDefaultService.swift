//
//  UserDefaultService.swift
//  CurrencyApp
//
//  Created by YK Poh on 16/06/2022.
//

import Foundation
import UIKit

enum UserDefaultServiceKey: String {
    case amount
    case selectedCurrency
}

class UserDefaultService {
    static func encodeAndSave<T>(key: UserDefaultServiceKey, value: T) where T: Codable {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(value)
            save(key: key, value: data)
        } catch {
            print(error)
        }
    }
    
    static func save<T>(key: UserDefaultServiceKey, value: T) where T: Codable {
        UserDefaults.standard.set(value, forKey: key.rawValue)
    }
    
    static func load<T>(key: UserDefaultServiceKey) -> T? where T: Codable {
        switch key {
        case .amount:
            return UserDefaults.standard.double(forKey: key.rawValue) as? T
        case .selectedCurrency:
            guard let data = UserDefaults.standard.data(forKey: key.rawValue) else { return nil }
            do {
                let decoder = JSONDecoder()
                let object = try decoder.decode(T.self, from: data)
                return object
            } catch {
                print(error)
            }
        }
        
        return nil
    }
}
