//
//  AddExpenseView.swift
//  RespectMoney
//
//  Created by Miguel Duran on 14-03-25.
//

import SwiftUI
import SwiftData

struct AddExpenseView: View {
    @AppStorage("currency") private var currency: String = "USD"
    @AppStorage("defaultCategory") private var category: String = "Food"
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String = ""
    @State private var amountText: String = ""
    @State private var date: Date = Date()
    @State private var showError: Bool = false
    
    let categories = ["Food", "Transport", "Shopping", "Entertainment", "Bills", "Other"]
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Title", text: $title)
                TextField("Amount", text: $amountText)
                    .keyboardType(.decimalPad)
                    .onChange(of: amountText) { oldValue, newValue in
                        if newValue.isEmpty {
                            return
                        } else {
                            let decimalCount = amountText.filter { $0 == "." }.count
                            if decimalCount > 1 {
                                amountText.removeLast()
                            }
                            
                            if amountText == "." {
                                amountText = ""
                            }
                        }
                    }
                
                Picker("Category", selection: $category) {
                    ForEach(categories, id: \.self) { category in
                        Text(category).tag(category)
                    }
                }
    
                DatePicker("Date", selection: $date, displayedComponents: .date)
            }
            .navigationTitle("Add Expense")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        addExpense()
                    }
                    .disabled(title.isEmpty || amountText.isEmpty || category.isEmpty)
                }
            }
            .alert("Invalid Amount", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Please enter a valid amount greater than zero.")
            }
        }
    }
    
    private func addExpense() {
        guard let amount = Double(amountText), amount > 0 else {
            showError = true
            return
        }
        
        let newExpense = Expense(title: title, amount: amount, category: category, date: date)
        modelContext.insert(newExpense)
        dismiss()
    }
}

#Preview {
    do {
        let container = try ModelContainer(for: Expense.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        return AddExpenseView()
            .modelContainer(container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
