//
//  SettingsView.swift
//  RespectMoney
//
//  Created by Miguel Duran on 14-03-25.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("currency") private var currency: String = "USD"
    @AppStorage("defaultCategory") private var defaultCategory: String = "Food"

    let currencies = ["CLP", "USD", "EUR", "GBP", "JPY", "CAD", "AUD"]
    let categories = ["Food", "Transport", "Shopping", "Entertainment", "Bills", "Other"]

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Preferences")) {
                    Picker("Currency", selection: $currency) {
                        ForEach(currencies, id: \.self) { currency in
                            Text(currency).tag(currency)
                        }
                    }

                    Picker("Default Category", selection: $defaultCategory) {
                        ForEach(categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}
