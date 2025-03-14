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

    @State var expense: Expense

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

            }
            .navigationTitle("Edit Expense")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        try? modelContext.save()
                        dismiss()
                    }
                    .disabled(expense.title.isEmpty || expense.amount <= 0)
                }
            }
        }
    }
}

#Preview {
    do {
        let container = try ModelContainer(for: Expense.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        
        let previewExpense = Expense(title: "Groceries", amount: 45.99, category: "Food", date: Date())
        
        let context = ModelContext(container)
        context.insert(previewExpense)
        
        return EditExpenseView(expense: previewExpense)
            .modelContainer(container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}

