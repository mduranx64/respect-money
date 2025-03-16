//
//  ExpenseListView.swift
//  RespectMoney
//
//  Created by Miguel Duran on 14-03-25.
//

import SwiftUI
import SwiftData

struct TransactionListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var transactions: [Transaction]
    
    @State private var selectedCategory: String = "All"
    @State private var selectedMonth: Date
    @State private var selectedTransaction: Transaction?
    @State private var showAddTransaction: Bool = false
    @AppStorage("currency") private var currency: String = "USD"
    
    @AppStorage("categories") private var categoriesString: String = ""
    
    init() {
        _selectedMonth = State(initialValue: TransactionListView.normalizeToMonth(Date()))
    }
    
    var categories: [String] {
        var list = categoriesString.components(separatedBy: ",").filter { !$0.isEmpty }
        list.insert("All", at: 0)
        return list
    }
    
    /// ✅ Generate a list of months for the **current year** only
    var monthOptions: [Date] {
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        
        return (1...12).compactMap { month in
            calendar.date(from: DateComponents(year: currentYear, month: month))
        }
    }
    
    /// ✅ Format month names (e.g., "March")
    func monthName(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM" // Example: "March"
        return formatter.string(from: date)
    }
    
    /// ✅ Filter transaction by selected month and category
    var filteredTransactions: [Transaction] {
        let calendar = Calendar.current
        return transactions.filter { expense in
            let isSameMonth = calendar.isDate(expense.date, equalTo: selectedMonth, toGranularity: .month)
            return isSameMonth && (selectedCategory == "All" || expense.category == selectedCategory)
        }
    }
    
    var groupedTransactions: [String: [Transaction]] {
        Dictionary(grouping: filteredTransactions, by: { $0.category })
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
                    
                    Picker("Select Month", selection: $selectedMonth) {
                        ForEach(monthOptions, id: \.self) { month in
                            Text(monthName(for: month)).tag(month)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                List {
                    ForEach(groupedTransactions.keys.sorted(), id: \.self) { category in
                        Section(header: Text(category).font(.headline)) {
                            ForEach(groupedTransactions[category] ?? []) { transaction in
                                Button {
                                    selectedTransaction = transaction
                                } label: {
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(transaction.title)
                                                .font(.headline)
                                                .foregroundStyle(.secondary)
                                            Text(transaction.category)
                                                .font(.subheadline)
                                                .foregroundStyle(.secondary)
                                        }
                                        Spacer()
                                        Text(transaction.amount.formattedAsCurrency(currency))
                                            .font(.headline)
                                            .foregroundStyle(.secondary)
                                    }
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                            }
                            .onDelete(perform: deleteTransaction)
                        }
                    }
                }
                .sheet(item: $selectedTransaction) { transaction in
                    EditTransactionView(transaction: transaction)
                }
            }
            .navigationTitle("Transactions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddTransaction = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title)
                    }
                }
            }
        }
        .sheet(isPresented: $showAddTransaction) {
            AddTransactionView()
        }
    }
    
    private func deleteTransaction(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(transactions[index])
        }
    }
    
    static func normalizeToMonth(_ date: Date) -> Date {
       let calendar = Calendar.current
       let components = calendar.dateComponents([.year, .month], from: date)
       return calendar.date(from: components) ?? date
   }
}

#Preview {
    TransactionListView()
        .modelContainer(previewModelContainer)
}
