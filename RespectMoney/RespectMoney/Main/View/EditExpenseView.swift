//
//  EditExpenseView.swift
//  RespectMoney
//
//  Created by Miguel Duran on 14-03-25.
//

import SwiftUI
import SwiftData

import SwiftUI

/// ✅ A separate model for editing (prevents unwanted auto-saves)
struct ExpenseEditModel {
    var title: String
    var amount: String
    var category: String
    var date: Date
}

struct EditExpenseView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var editModel: ExpenseEditModel // Temporary local copy
    @State private var showDeleteAlert: Bool = false
    @AppStorage("categories") private var categoriesString: String = ""

    var categories: [String] {
        categoriesString.components(separatedBy: ",").filter { !$0.isEmpty }
    }

    let expense: Expense

    init(expense: Expense) {
        self.expense = expense
        _editModel = State(initialValue: ExpenseEditModel(
            title: expense.title,
            amount: EditExpenseView.formatNumber(expense.amount), // ✅ Use formatter for accurate display
            category: expense.category,
            date: expense.date
        ))
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Title", text: $editModel.title)
                    .textInputAutocapitalization(.sentences)
                    .autocorrectionDisabled(true)

                // ✅ Use a separate model to prevent auto-saving
                TextField("Amount", text: $editModel.amount)
                    .numberInput($editModel.amount)

                Picker("Category", selection: $editModel.category) {
                    ForEach(categories, id: \.self) { category in
                        Text(category)
                    }
                }

                DatePicker("Date", selection: $editModel.date, displayedComponents: .date)

                Section {
                    Button("Delete") {
                        showDeleteAlert = true
                    }
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity)
                }
                .alert("Delete Expense?", isPresented: $showDeleteAlert) {
                    Button("Cancel", role: .cancel) { }
                    Button("Delete", role: .destructive) {
                        modelContext.delete(expense)
                        dismiss()
                    }
                } message: {
                    Text("Are you sure you want to delete this expense? This action cannot be undone.")
                }
            }
            .navigationTitle("Edit Expense")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss() // ✅ Discard all changes
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        if let amount = parseNumber(editModel.amount) {
                            editModel.amount = EditExpenseView.formatNumber(amount) // ✅ Ensure correct formatting
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
            expense.title = editModel.title
            expense.amount = amount // ✅ Store correctly rounded value
            expense.category = editModel.category
            expense.date = editModel.date

            try modelContext.save() // ✅ Save only explicitly
            dismiss() // Close the view
        } catch {
            print("Failed to save expense: \(error.localizedDescription)")
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
    let previewExpense = Expense(title: "Groceries", amount: 45.99, category: "Food", date: Date())
    let context = ModelContext(previewModelContainer)
    context.insert(previewExpense)
        
    return EditExpenseView(expense: previewExpense)
            .modelContainer(previewModelContainer)
}

