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

    @Bindable var expense: Expense

    let categories = ["Food", "Transport", "Shopping", "Entertainment", "Bills", "Other"]

    var body: some View {
        NavigationStack {
            Form {
                TextField("Title", text: $expense.title)
                TextField("Amount", value: $expense.amount, format: .number)
                    .keyboardType(.decimalPad)

                Picker("Category", selection: $expense.category) {
                    ForEach(categories, id: \.self) { category in
                        Text(category)
                    }
                }

                DatePicker("Date", selection: $expense.date, displayedComponents: .date)

                Button("Save Changes") {
                    try? modelContext.save()
                    dismiss()
                }
                .disabled(expense.title.isEmpty || expense.amount <= 0)
            }
            .navigationTitle("Edit Expense")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
