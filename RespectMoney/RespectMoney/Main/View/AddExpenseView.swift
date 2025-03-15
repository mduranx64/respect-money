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
    @AppStorage("categories") private var categoriesString: String = ""

    var categories: [String] {
        categoriesString.components(separatedBy: ",").filter { !$0.isEmpty }
    }
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String = ""
    @State private var amount: String = ""
    @State private var date: Date = Date()
    @State private var showError: Bool = false
    
    @State private var labelText: String = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                Form {
                    TextField("Title", text: $title)
                        .textInputAutocapitalization(.sentences)
                        .autocorrectionDisabled(true)
                    
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                        .numberInput($amount)
                    
                    Picker("Category", selection: $category) {
                        ForEach(categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
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
                            addExpense()
                        }
                        .disabled(title.isEmpty || amount.isEmpty || category.isEmpty)
                    }
                }
                .alert("Invalid Amount", isPresented: $showError) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text("Please enter a valid amount greater than zero.")
                }
            }
        }
    }
    
    private func addExpense() {
        guard let amount = Double(amount), amount > 0 else {
            showError = true
            return
        }
        
        let newExpense = Expense(title: title, amount: amount, category: category, date: date)
        modelContext.insert(newExpense)
        dismiss()
    }
}

#Preview {
    AddExpenseView()
        .modelContainer(previewModelContainer)
    
}

struct LabelTextField: View {
    var label: String
    @Binding var text: String
    var body: some View {
        HStack {
            Text(label)
            Spacer()
            TextField("", text: $text)
        }
    }
}
