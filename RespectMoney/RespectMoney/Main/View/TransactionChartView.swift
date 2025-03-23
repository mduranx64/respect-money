//
//  TransactionChartView.swift
//  RespectMoney
//
//  Created by Miguel Duran on 14-03-25.
//

import SwiftUI
import Charts
import SwiftData



struct TransactionChartView: View {
    @Query private var transactions: [Transaction]
    @AppStorage("currency") private var currency: String = "USD"
    
    let systemColors: [Color] = [
        .red, .orange, .yellow, .green, .mint, .teal, .cyan,
        .blue, .indigo, .purple, .pink, .brown, .gray
    ]
    
    /// ✅ Compute total income and expense separately
    var totalIncome: Double {
        transactions.filter { $0.type == "Income" }.reduce(0) { $0 + $1.amount }
    }
    
    var totalExpense: Double {
        transactions.filter { $0.type == "Expense" }.reduce(0) { $0 + $1.amount }
    }

    var totalAmount: Double {
        totalIncome + totalExpense
    }
    
    var totalSavings: Double {
        totalIncome - totalExpense
    }
    
    /// ✅ Computed property that assigns colors in order without modifying state
    var categoryColorMap: [String: Color] {
        var tempMap: [String: Color] = [:]
        let allCategories = expenseByCategory.map { $0.category }.sorted() // ✅ Get sorted category list
        for (index, category) in allCategories.enumerated() {
            tempMap[category] = systemColors[index % systemColors.count] // ✅ Assign colors in order
        }
        return tempMap
    }

    /// ✅ Function to retrieve color for a given category
    func colorForCategory(_ category: String) -> Color {
        return categoryColorMap[category] ?? .gray // ✅ Always returns color from computed dictionary
    }

    /// ✅ Group expenses by category (ignoring income)
    var expenseByCategory: [(category: String, total: Double, percentage: Double)] {
        let expenses = transactions.filter { $0.type == "Expense" }
        let totalExpenses = expenses.reduce(0) { $0 + $1.amount }

        return Dictionary(grouping: expenses, by: { $0.category })
            .mapValues { $0.reduce(0) { $0 + $1.amount } }
            .map { (category, total) in
                let percentage = totalExpenses > 0 ? (total / totalExpenses) * 100 : 0
                return (category: category, total: total, percentage: percentage)
            }
            .sorted { $0.total > $1.total }
    }

    var body: some View {
        NavigationStack {
            VStack {
                // ✅ Show total income and expense
                VStack {
                    Text("Income: \(totalIncome.formattedAsCurrency(currency))")
                        .foregroundColor(.green)
                        .bold()
                    
                    Text("Expenses: \(totalExpense.formattedAsCurrency(currency))")
                        .foregroundColor(.red)
                        .bold()

                    Text("Savings: \(totalSavings.formattedAsCurrency(currency))")
                        .foregroundColor(.blue)
                        .bold()
                }
                .font(.title3)
                .padding(.bottom, 10)

                GeometryReader { geometry in
                    TabView {

                        VStack {
                            Text("Income vs. Expense & Savings")
                                .font(.headline)

                            Chart {
                                // ✅ Bar 1: Total Income
                                BarMark(
                                    x: .value("Type", "Total Income"),
                                    y: .value("Amount", totalIncome)
                                )
                                .foregroundStyle(.green)
                                .cornerRadius(5)
                                .annotation(position: .top) {
                                    VStack {
                                        Text("\(totalIncome / totalIncome * 100, specifier: "%.1f")%")
                                            .font(.caption)
                                            .bold()
                                            .foregroundColor(.green)
                                        Text(totalIncome.formattedAsCurrency(currency))
                                            .font(.caption)
                                            .foregroundColor(.primary)
                                    }
                                    .padding(5)
                                    .cornerRadius(5)
                                }
                                
                                // ✅ Bar 2: Total Expenses
                                BarMark(
                                    x: .value("Type", "Total Expenses"),
                                    y: .value("Amount", totalExpense)
                                )
                                .foregroundStyle(.red)
                                .cornerRadius(5)
                                .annotation(position: .top) {
                                    VStack {
                                        Text("\((totalExpense / totalAmount) * 100, specifier: "%.1f")%")
                                            .font(.caption)
                                            .bold()
                                            .foregroundColor(.red)
                                        Text(totalExpense.formattedAsCurrency(currency))
                                            .font(.caption)
                                            .foregroundColor(.primary)
                                    }
                                    .padding(5)
                                    .cornerRadius(5)
                                }

                                // ✅ Bar 3: Net Savings (Income - Expenses)
                                BarMark(
                                    x: .value("Type", "Net Savings"),
                                    y: .value("Amount", totalSavings)
                                )
                                .foregroundStyle(.blue)
                                .cornerRadius(5)
                                .annotation(position: .top) {
                                    VStack {
                                        Text("\((totalSavings / totalAmount) * 100, specifier: "%.1f")%")
                                            .font(.caption)
                                            .bold()
                                            .foregroundColor(.blue)
                                        Text(totalSavings.formattedAsCurrency(currency))
                                            .font(.caption)
                                            .foregroundColor(.primary)
                                    }
                                    .padding(5)
                                    .cornerRadius(5)
                                }

                            }
                            .frame(width: geometry.size.width)
                        }
                        .tabItem { Label("Income vs Expense", systemImage: "chart.bar.fill") }

                        // ✅ Second Chart: Expenses by Category
                        VStack {
                            Text("Expenses by Category")
                                .font(.headline)
                            Chart {
                                ForEach(expenseByCategory, id: \.category) { data in
                                    BarMark(
                                        x: .value("Category", data.category),
                                        y: .value("Total", data.total)
                                    )
                                    .cornerRadius(5)
                                    .foregroundStyle(colorForCategory(data.category))
                                    .annotation(position: .top) {
                                        VStack {
                                            Text("\(data.percentage, specifier: "%.1f")%")
                                                .font(.caption)
                                                .bold()
                                                .foregroundStyle(colorForCategory(data.category))
                                            Text(data.total.formattedAsCurrency(currency))
                                                .font(.caption)
                                        }
                                        .padding(5)
                                        .cornerRadius(5)
                                    }
                                }
                            }
                            .frame(width: geometry.size.width)
                        }
                        .tabItem { Label("Expenses by Category", systemImage: "chart.pie.fill") }
                    }
                    .tabViewStyle(.page)
                }
            }
            .padding()
            .navigationTitle("Transaction Breakdown")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    TransactionChartView()
        .modelContainer(previewModelContainer)
}
