//
//  AddTransactionView.swift
//  RespectMoney
//
//  Created by Miguel Duran on 14-03-25.
//

import SwiftUI
import SwiftData

struct AddTransactionView: View {
    @AppStorage("currency") private var currency: String = "USD"
    @AppStorage("defaultCategory") private var defaultCategory: String = "Food"
    @AppStorage("expenseCategories") private var expenseCategoriesString: String = ""
    @AppStorage("incomeCategories") private var incomeCategoriesString: String = ""
    var expenseCategories: [String] {
        expenseCategoriesString.components(separatedBy: ",").filter { !$0.isEmpty }
    }
    var incomeCategories: [String] {
        incomeCategoriesString.components(separatedBy: ",").filter { !$0.isEmpty }
    }
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String = ""
    @State private var amount: String = ""
    @State private var date: Date = Date()
    @State private var showError: Bool = false
    @State private var transactionType: String = TransactionType.expense.rawValue
    @State private var labelText: String = ""
    @State private var selectedExpenseCategory: String = ""
    @State private var selectedIncomeCategory: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Picker("Type", selection: $transactionType) {
                    ForEach(transactionTypes, id: \.self) { type in
                        Text(type).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                
                TextField("Title", text: $title)
                    .textInputAutocapitalization(.sentences)
                    .autocorrectionDisabled(true)
                    .font(.headline)
                
                TextField("Amount", text: $amount)
                    .keyboardType(.decimalPad)
                    .numberInput($amount)
                    .font(.largeTitle)
                
                if transactionType == TransactionType.expense.rawValue {
                    Picker("Expense Category", selection: $selectedExpenseCategory) {
                        ForEach(expenseCategories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                    .pickerStyle(.wheel)
                } else {
                    Picker("Income Category", selection: $selectedIncomeCategory) {
                        ForEach(incomeCategories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                    .pickerStyle(.wheel)
                }
                
                DatePicker("Date", selection: $date, displayedComponents: .date)
            }
            .navigationTitle("Add Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        addTransaction()
                    }
                    .disabled(title.isEmpty || amount.isEmpty)
                }
            }
            .alert("Invalid Amount", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Please enter a valid amount greater than zero.")
            }
            
        }
        .onAppear {
            selectedExpenseCategory = defaultCategory
            selectedIncomeCategory = incomeCategories.first ?? ""
        }
    }
    
    private func addTransaction() {
        guard let amount = Double(amount), amount > 0 else {
            showError = true
            return
        }
        let category = transactionType == TransactionType.expense.rawValue ? selectedExpenseCategory : selectedIncomeCategory

        let newTransaction = Transaction(
            title: title,
            amount: amount,
            category: category,
            date: date,
            type: transactionType
        )
        modelContext.insert(newTransaction)
        dismiss()
    }
}

#Preview {
    AddTransactionView()
        .modelContainer(previewModelContainer)
    
}
