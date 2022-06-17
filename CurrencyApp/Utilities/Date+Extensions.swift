//
//  Date+Extensions.swift
//  CurrencyApp
//
//  Created by YK Poh on 17/06/2022.
//

import Foundation

extension Date {
    func minutesDifference(date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: self, to: date).minute ?? 0
    }
}
