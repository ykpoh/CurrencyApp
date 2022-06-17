//
//  FileStorageService.swift
//  CurrencyApp
//
//  Created by YK Poh on 15/06/2022.
//

import Foundation

enum FileStorageServiceType: String {
    case currencies
    case latestExchangeRates
}

protocol FileStorageServiceProtocol {
    static func save<T>(value: T, fileType: FileStorageServiceType) where T: Codable
    static func load<T>(fileType: FileStorageServiceType) -> T? where T: Codable
}

class FileStorageService: FileStorageServiceProtocol {
    static func save<T>(value: T, fileType: FileStorageServiceType) where T: Codable {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(value)
            let fileURL = getFileURL(fileType)
            try data.write(to: fileURL)
        } catch {
            print(error)
        }
    }
    
    static func load<T>(fileType: FileStorageServiceType) -> T? where T: Codable {
        do {
            let fileURL = getFileURL(fileType)
            let data = try Data(contentsOf: fileURL)
            let model = try JSONDecoder().decode(T.self, from: data)
            return model
        } catch {
            clear(fileType)
            return nil
        }
    }
    
    private static func getFileURL(_ fileType: FileStorageServiceType) -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("\(fileType.self).json")
    }
    
    private static func clear(_ fileType: FileStorageServiceType) {
        let fileURL = getFileURL(fileType)
        try? FileManager.default.removeItem(at: fileURL)
    }
}
