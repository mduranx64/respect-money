//
//  Extension.swift
//  RespectMoney
//
//  Created by Miguel Duran on 15-03-25.
//

import SwiftUI

extension Double {
    /// ✅ Formats a Double as currency using the selected currency
    func formattedAsCurrency(_ currency: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        formatter.currencySymbol = (formatter.currencySymbol ?? "") + " "
        formatter.maximumFractionDigits = 2

        return formatter.string(from: NSNumber(value: self)) ?? "\(currency) \(self)"
    }
}
