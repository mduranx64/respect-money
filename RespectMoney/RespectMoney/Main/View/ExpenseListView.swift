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
    @AppStorage("currency") private var currency: String = "USD" // Default to USD if no value exists
    
    @AppStorage("categories") private var categoriesString: String = ""
    
    var categories: [String] {
        var list = categoriesString.components(separatedBy: ",").filter { !$0.isEmpty }
        list.insert("All", at: 0)
        return list
    }
    
    var filteredExpenses: [Expense] {
        expenses.filter { expense in
            (selectedCategory == "All" || expense.category == selectedCategory) &&
            Calendar.current.isDate(expense.date, inSameDayAs: selectedDate)
        }
    }
    
    var groupedExpenses: [String: [Expense]] {
        Dictionary(grouping: filteredExpenses, by: { $0.category })
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                
                HStack {
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    DatePicker("Fecha", selection: $selectedDate, displayedComponents: .date)
                        .labelsHidden()
                }
                
                List {
                    ForEach(groupedExpenses.keys.sorted(), id: \.self) { category in
                        Section(header: Text(category).font(.headline)) {
                            ForEach(groupedExpenses[category] ?? []) { expense in
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
                                        Text(expense.amount.formattedAsCurrency(currency))
                                            .font(.headline)
                                            .foregroundStyle(.secondary)
                                    }
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                            }
                            .onDelete(perform: deleteExpense)
                        }
                    }
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
