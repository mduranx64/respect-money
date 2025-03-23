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
    
    @State private var selectedExpenseCategory: String = "All"
    @State private var transactionType: String = "All"
    @State private var selectedMonth: Date
    @State private var selectedTransaction: Transaction?
    @State private var showAddTransaction: Bool = false
    @AppStorage("currency") private var currency: String = "USD"
    
    @AppStorage("expenseCategories") private var expenseCategoriesString: String = ""
    
    init() {
        _selectedMonth = State(initialValue: TransactionListView.normalizeToMonth(Date()))
    }
    
    var expenseCategories: [String] {
        var list = expenseCategoriesString.components(separatedBy: ",").filter { !$0.isEmpty }
        list.insert("All", at: 0)
        return list
    }
    
    var transactionsTypesWithAll: [String] {
        var list = transactionTypes
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
        transactions.filter { transaction in
            let isSameMonth = Calendar.current.isDate(transaction.date, equalTo: selectedMonth, toGranularity: .month)
            let matchesCategory = selectedExpenseCategory == "All" || transaction.category == selectedExpenseCategory
            let matchesType = transactionType == "All" || transaction.type == transactionType // ✅ Filter by type
            return isSameMonth && matchesCategory && matchesType
        }
    }
    
    /// ✅ Group transactions **first by type, then by category**
    var groupedTransactions: [String: [String: [Transaction]]] {
        let groupedByType = Dictionary(grouping: filteredTransactions, by: { $0.type })
        
        return groupedByType.mapValues { transactions in
            Dictionary(grouping: transactions, by: { $0.category })
        }
    }
    
    /// ✅ Compute total income & expenses per type
    var totalPerType: [String: Double] {
        var totals: [String: Double] = [:]
        for (type, transactions) in groupedTransactions {
            totals[type] = transactions.values.flatMap { $0 }.reduce(0) { $0 + $1.amount }
        }
        return totals
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack(spacing: 0) {
                    Picker("Transaction Type", selection: $transactionType) {
                        ForEach(transactionsTypesWithAll, id: \.self) { transactionType in
                            Text(transactionType).tag(transactionType)
                            
                        }
                    }
                    .pickerStyle(.menu)
                    
                    Picker("Category", selection: $selectedExpenseCategory) {
                        ForEach(expenseCategories, id: \.self) { category in
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
                .frame(maxWidth: .infinity, alignment: .center)
                
                List {
                    ForEach(groupedTransactions.keys.sorted(), id: \.self) { type in
                        let total = totalPerType[type] ?? 0
                        
                        Section(header: HStack {
                            Text(type)
                                .font(.title2)
                                .bold()
                            Spacer()
                            Text(total.formattedAsCurrency(currency)) // ✅ Show total per type
                                .foregroundColor(type == TransactionType.expense.rawValue ? .red : .green)
                                .bold()
                        }) {
                            ForEach(groupedTransactions[type]!.keys.sorted(), id: \.self) { category in
                                Section(header: Text(category).font(.headline)) {
                                    ForEach(groupedTransactions[type]![category] ?? []) { transaction in
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
                                                if transaction.type == TransactionType.expense.rawValue {
                                                    Text("-\(transaction.amount.formattedAsCurrency(currency))")
                                                        .font(.headline)
                                                        .foregroundStyle(.red)
                                                } else {
                                                    Text("+\(transaction.amount.formattedAsCurrency(currency))")
                                                        .font(.headline)
                                                        .foregroundStyle(.green)
                                                }
                                            }
                                            .contentShape(Rectangle())
                                        }
                                        .buttonStyle(.plain)
                                    }
                                    .onDelete(perform: deleteTransaction)
                                }
                            }
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
