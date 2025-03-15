//
//  ExpenseListView.swift
//  RespectMoney
//
//  Created by Miguel Duran on 14-03-25.
//

import SwiftUI
import SwiftData

struct ExpenseListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var expenses: [Expense]
    
    @State private var selectedCategory: String = "All"
    @State private var selectedDate: Date = Date()
    @State private var selectedExpense: Expense?
    @State private var showAddExpense: Bool = false
    
    let categories = ["All", "Food", "Transport", "Shopping", "Entertainment", "Bills", "Other"]
    
    var filteredExpenses: [Expense] {
        expenses.filter { expense in
            (selectedCategory == "All" || expense.category == selectedCategory) &&
            Calendar.current.isDate(expense.date, inSameDayAs: selectedDate)
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                
                HStack {
                    Picker("Category😱", selection: $selectedCategory) {
                        ForEach(categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    DatePicker("", selection: $selectedDate, displayedComponents: .date)
                        .labelsHidden()
                }
                .padding()
                
                List {
                    ForEach(filteredExpenses) { expense in
                        Button {
                            selectedExpense = expense
                        } label: {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(expense.title)
                                        .font(.headline)
                                        .foregroundStyle(.secondary)
                                    Text(expense.category)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text("$\(expense.amount, specifier: "%.2f")")
                                    .font(.headline)
                                    .foregroundStyle(.secondary)
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                    .onDelete(perform: deleteExpense)
                }
                .sheet(item: $selectedExpense) { expense in
                    EditExpenseView(expense: expense)
                }
            }
            .navigationTitle("Expenses")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddExpense = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title)
                    }
                }
            }
        }
        .sheet(isPresented: $showAddExpense) {
            AddExpenseView()
        }
    }
    
    private func deleteExpense(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(expenses[index])
        }
    }
}

#Preview {
    ExpenseListView()
            .modelContainer(previewModelContainer)
}
