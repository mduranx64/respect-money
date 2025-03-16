//
//  EditTransactionView.swift
//  RespectMoney
//
//  Created by Miguel Duran on 14-03-25.
//

import SwiftUI
import SwiftData

import SwiftUI

/// ✅ A separate model for editing (prevents unwanted auto-saves)
struct TransactionEditModel {
    var title: String
    var amount: String
    var category: String
    var date: Date
    var type: String
}

struct EditTransactionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var editModel: TransactionEditModel // Temporary local copy
    @State private var showDeleteAlert: Bool = false
    @AppStorage("expenseCategories") private var expenseCategoriesString: String = ""
    @AppStorage("incomeCategories") private var incomeCategoriesString: String = ""
    var expenseCategories: [String] {
        expenseCategoriesString.components(separatedBy: ",").filter { !$0.isEmpty }
    }
    var incomeCategories: [String] {
        incomeCategoriesString.components(separatedBy: ",").filter { !$0.isEmpty }
    }
    @State private var transactionType: String = TransactionType.expense.rawValue

    let transaction: Transaction
    
    init(transaction: Transaction) {
        self.transaction = transaction
        _editModel = State(initialValue: TransactionEditModel(
            title: transaction.title,
            amount: EditTransactionView.formatNumber(transaction.amount), // ✅ Use formatter for accurate display
            category: transaction.category,
            date: transaction.date,
            type: transaction.type
        ))
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Picker("Type", selection: $transactionType) {
                    ForEach(transactionTypes, id: \.self) { type in
                        Text(type).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                
                TextField("Title", text: $editModel.title)
                    .textInputAutocapitalization(.sentences)
                    .autocorrectionDisabled(true)
                    .font(.headline)
                
                // ✅ Use a separate model to prevent auto-saving
                TextField("Amount", text: $editModel.amount)
                    .numberInput($editModel.amount)
                    .font(.largeTitle)
                
                if transactionType == TransactionType.expense.rawValue {
                    Picker("Expense Category", selection: $editModel.category) {
                        ForEach(expenseCategories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                    .pickerStyle(.wheel)
                } else {
                    
                    Picker("Income Category", selection: $editModel.category) {
                        ForEach(incomeCategories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                    .pickerStyle(.wheel)
                }
                
                DatePicker("Date", selection: $editModel.date, displayedComponents: .date)
                
                Section {
                    Button("Delete") {
                        showDeleteAlert = true
                    }
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity)
                }
                .alert("Delete Transaction?", isPresented: $showDeleteAlert) {
                    Button("Cancel", role: .cancel) { }
                    Button("Delete", role: .destructive) {
                        modelContext.delete(transaction)
                        dismiss()
                    }
                } message: {
                    Text("Are you sure you want to delete this transaction? This action cannot be undone.")
                }
            }
            .navigationTitle("Edit Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss() // ✅ Discard all changes
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        if let amount = parseNumber(editModel.amount) {
                            editModel.amount = EditTransactionView.formatNumber(amount) // ✅ Ensure correct formatting
                            saveChanges(amount: amount)
                        }
                    }
                    .disabled(editModel.title.isEmpty || parseNumber(editModel.amount) ?? 0 <= 0)
                }
            }
            
        }
    }
    
    /// ✅ **Save only when user taps "Save"**
    private func saveChanges(amount: Double) {
        do {
            transaction.title = editModel.title
            transaction.amount = amount // ✅ Store correctly rounded value
            transaction.category = editModel.category
            transaction.date = editModel.date
            transaction.type = editModel.type
            
            try modelContext.save() // ✅ Save only explicitly
            dismiss() // Close the view
        } catch {
            print("Failed to save transaction: \(error.localizedDescription)")
        }
    }
    
    /// ✅ **Correctly parse numbers based on locale**
    private func parseNumber(_ text: String) -> Double? {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2 // ✅ Ensures correct decimal precision
        return formatter.number(from: text)?.doubleValue
    }
    
    /// ✅ **Formats numbers correctly based on locale**
    private static func formatNumber(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2 // ✅ Round to 2 decimal places
        formatter.minimumFractionDigits = 2 // ✅ Always show 2 decimal places
        return formatter.string(from: NSNumber(value: value)) ?? ""
    }
}

#Preview {
    let previewTransaction = Transaction(title: "Groceries", amount: 45.99, category: "Food", date: Date(), type: TransactionType.expense.rawValue)
    let context = ModelContext(previewModelContainer)
    context.insert(previewTransaction)
    
    return EditTransactionView(transaction: previewTransaction)
        .modelContainer(previewModelContainer)
}

