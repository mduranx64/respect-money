//
//  NumberInputModifier.swift
//  RespectMoney
//
//  Created by Miguel Duran on 15-03-25.
//

import SwiftUI

/// A custom modifier to validate numeric input in a TextField
struct NumberInputModifier: ViewModifier {
    @Binding var text: String

    func body(content: Content) -> some View {
        let locale = Locale.current
        let decimalSeparator = locale.decimalSeparator ?? "."

        return content
            .keyboardType(.decimalPad)
            .onChange(of: text) { oldValue, newValue in
                // Allow empty input to keep placeholder visible
                if newValue.isEmpty {
                    return
                }

                // Remove non-numeric characters (allow only digits and one decimal separator)
                text = newValue.filter { "0123456789\(decimalSeparator)".contains($0) }

                // Prevent multiple leading zeros (0005 -> 5)
                while text.count > 1,
                      text.first == "0",
                      let secondCharIndex = text.index(text.startIndex, offsetBy: 1, limitedBy: text.endIndex),
                      text[secondCharIndex] != Character(decimalSeparator) {
                    text.removeFirst()
                }

                // Ensure only one decimal point
                let decimalCount = text.filter { $0 == Character(decimalSeparator) }.count
                if decimalCount > 1 {
                    text.removeLast() // Remove extra decimal
                }

                // Prevent decimal as the first character
                if text == decimalSeparator {
                    text = ""
                }

                // Ensure valid double value (avoid NaN issues)
                if let doubleValue = Double(text), doubleValue.isNaN || doubleValue < 0 {
                    text = oldValue // Revert to last valid value
                }
            }
    }
}

// Extension for easier use
extension View {
    func numberInput(_ text: Binding<String>) -> some View {
        self.modifier(NumberInputModifier(text: text))
    }
}
