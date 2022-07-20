//
//  OpenExchangeRatesService.swift
//  CurrencyApp
//
//  Created by YK Poh on 11/06/2022.
//

import Foundation

enum OpenExchangeRatesError: Error {
    case invalidResponse(message: String)
    case noData(message: String)
    case failedRequest(message: String)
    case invalidData(message: String)
    case emptyURL(message: String)
}

protocol OpenExchangeRatesProtocol {
    static func getCurrencies(completion: @escaping ([Currency]?, OpenExchangeRatesError?) -> ())
    static func getLatestExchangeRates(completion: @escaping (LatestExchangeRate?, OpenExchangeRatesError?) -> ())
}

class OpenExchangeRatesService: OpenExchangeRatesProtocol {
    // Obtain app id by registering in openexchangerates.org
    private static let apiID = "app_id"
    private static let host = "openexchangerates.org"
    
    static func getCurrencies(completion: @escaping ([Currency]?, OpenExchangeRatesError?) -> ()) {
        defer {
            
            
        }
        var urlBuilder = URLComponents()
        urlBuilder.scheme = "https"
        urlBuilder.host = host
        urlBuilder.path = "/api/currencies.json"
        urlBuilder.queryItems = [
            URLQueryItem(name: "app_id", value: apiID)
        ]
        
        guard let url = urlBuilder.url else {
            completion(nil, .emptyURL(message: "Empty url detected."))
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
                    completion(nil, .invalidData(message: "Unable to decode OpenExchangeRates response: \(error.localizedDescription)"))
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
            completion(nil, .emptyURL(message: "Empty url detected."))
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
                    completion(nil, .invalidData(message: "Unable to decode OpenExchangeRates response: \(error.localizedDescription)"))
                }
            }
        }.resume()
    }
    
    private static func checkErrors(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> OpenExchangeRatesError? {
        guard error == nil else {
            return .failedRequest(message: "Failed request from OpenExchangeRates: \(error!.localizedDescription)")
        }
        
        guard data != nil else {
            return .noData(message: "No data returned from OpenExchangeRates")
        }
        
        guard let response = response as? HTTPURLResponse else {
            return .invalidResponse(message: "Unable to process OpenExchangeRates response")
        }
        
        guard response.statusCode == 200 else {
            return .failedRequest(message: "Failure response from OpenExchangeRates: \(response.statusCode)")
        }
        
        return nil
    }
}
