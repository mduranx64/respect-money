//
//  EditExpenseView.swift
//  RespectMoney
//
//  Created by Miguel Duran on 14-03-25.
//

import SwiftUI
import SwiftData

struct EditExpenseView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var tempExpense: Expense
    @State private var showDeleteAlert: Bool = false
    @State private var amountText: String = "" // Temporary variable

    let categories = ["Food", "Transport", "Shopping", "Entertainment", "Bills", "Other"]

    init(expense: Expense) {
        _tempExpense = State(initialValue: expense) // Create a local copy of the expense
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Title", text: $tempExpense.title)
                    .textInputAutocapitalization(.sentences)

                // ✅ Use a temporary variable for amount
                TextField("Amount", text: $amountText)
                    .numberInput($amountText) // Apply validation
                    .onAppear {
                        amountText = formatNumber(tempExpense.amount) // Load formatted value
                    }

                Picker("Category", selection: $tempExpense.category) {
                    ForEach(categories, id: \.self) { category in
                        Text(category)
                    }
                }

                DatePicker("Date", selection: $tempExpense.date, displayedComponents: .date)

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
                        modelContext.delete(tempExpense)
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
                        dismiss() // ✅ Discard changes
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        if let amount = parseNumber(amountText) {
                            tempExpense.amount = amount // ✅ Update amount correctly
                            saveChanges()
                        }
                    }
                    .disabled(tempExpense.title.isEmpty || parseNumber(amountText) ?? 0 <= 0)
                }
            }
        }
    }

    /// ✅ **Correctly parse the number based on locale**
    private func parseNumber(_ text: String) -> Double? {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current // Use user locale
        formatter.numberStyle = .decimal

        return formatter.number(from: text)?.doubleValue
    }

    /// ✅ **Formats numbers correctly based on locale**
    private func formatNumber(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? ""
    }

    /// ✅ **Only save when user taps "Save"**
    private func saveChanges() {
        do {
            try modelContext.save() // ✅ Save only when explicitly called
            dismiss() // Close the view
        } catch {
            print("Failed to save expense: \(error.localizedDescription)")
        }
    }
}

#Preview {
    let previewExpense = Expense(title: "Groceries", amount: 45.99, category: "Food", date: Date())
    let context = ModelContext(previewModelContainer)
    context.insert(previewExpense)
        
    return EditExpenseView(expense: previewExpense)
            .modelContainer(previewModelContainer)
}

