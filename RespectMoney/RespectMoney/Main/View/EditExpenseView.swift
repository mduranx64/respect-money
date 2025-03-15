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
    @State var showDeleteAlert: Bool = false
    
    let categories = ["Food", "Transport", "Shopping", "Entertainment", "Bills", "Other"]
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Title", text: $expense.title)
                    .textInputAutocapitalization(.sentences)
                
                TextField("Amount", value: $expense.amount, format: .number)
                    .keyboardType(.decimalPad)
                
                Picker("Category", selection: $expense.category) {
                    ForEach(categories, id: \.self) { category in
                        Text(category)
                    }
                }
                
                DatePicker("Date", selection: $expense.date, displayedComponents: .date)
                
                
                Section {
                    Button("Delete") {
                        showDeleteAlert = true
                    }
                    .foregroundStyle(.red)  // Set text color to red
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
    let previewExpense = Expense(title: "Groceries", amount: 45.99, category: "Food", date: Date())
    let context = ModelContext(previewModelContainer)
    context.insert(previewExpense)
        
    return EditExpenseView(expense: previewExpense)
            .modelContainer(previewModelContainer)
}

