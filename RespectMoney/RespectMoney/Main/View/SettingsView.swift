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

    let currencies = ["CLP", "USD", "EUR", "GBP", "JPY", "CAD", "AUD"]
    let categories = ["Food", "Transport", "Shopping", "Entertainment", "Bills", "Other"]
    @State private var showDeleteAlert = false

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
            let fetchDescriptor = FetchDescriptor<Expense>() // Fetch all expenses
            let allExpenses = try modelContext.fetch(fetchDescriptor)

            for expense in allExpenses {
                modelContext.delete(expense) // Delete each expense
            }
            
            try modelContext.save() // Save changes
        } catch {
            print("Error deleting all data: \(error.localizedDescription)")
        }
    }
}

#Preview {
    SettingsView()
}
