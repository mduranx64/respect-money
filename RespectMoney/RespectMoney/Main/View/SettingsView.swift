//
//  SettingsView.swift
//  RespectMoney
//
//  Created by Miguel Duran on 14-03-25.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @AppStorage("currency") private var currency: String = "USD"
    @AppStorage("defaultCategory") private var defaultCategory: String = "Food"
    @Environment(\.modelContext) private var modelContext
    @AppStorage("categories") private var categoriesString: String = ""
    
    var categories: [String] {
        categoriesString.components(separatedBy: ",").filter { !$0.isEmpty } // Convert CSV to array
    }
    /// ✅ Get a list of all available currency codes
    var allCurrencies: [String] {
        Set(Locale.availableIdentifiers.compactMap { Locale(identifier: $0).currency?.identifier })
            .sorted() // Sort alphabetically
    }

    @State private var showDeleteAlert = false

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Preferences")) {
                    Picker("Currency", selection: $currency) {
                        ForEach(allCurrencies, id: \.self) { currencyCode in
                            Text("\(currencyCode) (\(currencySymbol(for: currencyCode)))")
                                .tag(currencyCode)
                        }
                    }
                    .pickerStyle(.navigationLink)

                    Picker("Default Category", selection: $defaultCategory) {
                        ForEach(categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                }
                Section {
                    NavigationLink("Expense Categories") {
                        ExpenseCategoriesView()
                    }
                    
                    NavigationLink("Income Categories") {
                        IncomeCategoriesView()
                    }
                }
                
                Section {
                    Button("Delete all data") {
                        showDeleteAlert = true
                    }
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity)
                }
                .alert("Delete all expenses?", isPresented: $showDeleteAlert) {
                    Button("Cancel", role: .cancel) { }
                    Button("Delete", role: .destructive) {
                        deleteAllExpenses()
                    }
                } message: {
                    Text("Are you sure you want to delete all expenses? This action cannot be undone.")
                }
                
                
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func deleteAllExpenses() {
        do {
            let fetchDescriptor = FetchDescriptor<Transaction>() // Fetch all expenses
            let allExpenses = try modelContext.fetch(fetchDescriptor)

            for expense in allExpenses {
                modelContext.delete(expense) // Delete each expense
            }
            
            try modelContext.save() // Save changes
        } catch {
            print("Error deleting all data: \(error.localizedDescription)")
        }
    }
    
    /// ✅ Get the currency symbol for a given currency code
    private func currencySymbol(for currencyCode: String) -> String {
        let locale = Locale(identifier: Locale.identifier(fromComponents: [NSLocale.Key.currencyCode.rawValue: currencyCode]))
        return locale.currencySymbol ?? currencyCode
    }
}

#Preview {
    SettingsView()
}
