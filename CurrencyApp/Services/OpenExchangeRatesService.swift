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
}

class OpenExchangeRatesService {
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
        
        let url = urlBuilder.url!
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                guard error == nil else {
                    print("Failed request from OpenExchangeRates: \(error!.localizedDescription)")
                    completion(nil, .failedRequest)
                    return
                }
                
                guard let data = data else {
                    print("No data returned from OpenExchangeRates")
                    completion(nil, .noData)
                    return
                }
                
                guard let response = response as? HTTPURLResponse else {
                    print("Unable to process OpenExchangeRates response")
                    completion(nil, .invalidResponse)
                    return
                }
                
                guard response.statusCode == 200 else {
                    print("Failure response from OpenExchangeRates: \(response.statusCode)")
                    completion(nil, .failedRequest)
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let dictionaries = try decoder.decode([String:String].self, from: data)
                    let openExchangeRatesData = dictionaries.compactMap({ key, value in
                        Currency(symbol: key, name: value)
                    })
                    completion(openExchangeRatesData, nil)
                } catch {
                    print("Unable to decode OpenExchangeRates response: \(error.localizedDescription)")
                    completion(nil, .invalidData)
                }
            }
        }.resume()
    }
}
