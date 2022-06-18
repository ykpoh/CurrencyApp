//
//  OpenExchangeRatesService.swift
//  CurrencyApp
//
//  Created by YK Poh on 11/06/2022.
//

import Foundation

enum OpenExchangeRatesError: Error {
    case invalidResponse
    case noData
    case failedRequest
    case invalidData
    case emptyURL
}

protocol OpenExchangeRatesProtocol {
    static func getCurrencies(completion: @escaping ([Currency]?, OpenExchangeRatesError?) -> ())
    static func getLatestExchangeRates(completion: @escaping (LatestExchangeRate?, OpenExchangeRatesError?) -> ())
}

class OpenExchangeRatesService: OpenExchangeRatesProtocol {
    private static let apiID = "a8fef42612f0460ebea6884ed523ddcc"
    private static let host = "openexchangerates.org"
    
    static func getCurrencies(completion: @escaping ([Currency]?, OpenExchangeRatesError?) -> ()) {
        var urlBuilder = URLComponents()
        urlBuilder.scheme = "https"
        urlBuilder.host = host
        urlBuilder.path = "/api/currencies.json"
        urlBuilder.queryItems = [
            URLQueryItem(name: "app_id", value: apiID)
        ]
        
        guard let url = urlBuilder.url else {
            print("Empty url detected.")
            completion(nil, .emptyURL)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = checkErrors(data, response, error) {
                    completion(nil, error)
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let dictionaries = try decoder.decode([String:String].self, from: data!)
                    let currencyData = dictionaries.compactMap({ key, value in
                        Currency(symbol: key, name: value)
                    })
                    
                    completion(currencyData, nil)
                } catch {
                    print("Unable to decode OpenExchangeRates response: \(error.localizedDescription)")
                    completion(nil, .invalidData)
                }
            }
        }.resume()
    }
    
    static func getLatestExchangeRates(completion: @escaping (LatestExchangeRate?, OpenExchangeRatesError?) -> ()) {
        var urlBuilder = URLComponents()
        urlBuilder.scheme = "https"
        urlBuilder.host = host
        urlBuilder.path = "/api/latest.json"
        urlBuilder.queryItems = [
            URLQueryItem(name: "app_id", value: apiID)
        ]
        
        guard let url = urlBuilder.url else {
            print("Empty url detected.")
            completion(nil, .emptyURL)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = checkErrors(data, response, error) {
                    completion(nil, error)
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let ratesData = try decoder.decode(LatestExchangeRate.self, from: data!)
                    completion(ratesData, nil)
                } catch {
                    print("Unable to decode OpenExchangeRates response: \(error.localizedDescription)")
                    completion(nil, .invalidData)
                }
            }
        }.resume()
    }
    
    private static func checkErrors(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> OpenExchangeRatesError? {
        guard error == nil else {
            print("Failed request from OpenExchangeRates: \(error!.localizedDescription)")
            return .failedRequest
        }
        
        guard data != nil else {
            print("No data returned from OpenExchangeRates")
            return .noData
        }
        
        guard let response = response as? HTTPURLResponse else {
            print("Unable to process OpenExchangeRates response")
            return .invalidResponse
        }
        
        guard response.statusCode == 200 else {
            print("Failure response from OpenExchangeRates: \(response.statusCode)")
            return .failedRequest
        }
        
        return nil
    }
}
