//
//  ExpenseChartView.swift
//  RespectMoney
//
//  Created by Miguel Duran on 14-03-25.
//

import SwiftUI
import Charts
import SwiftData

import SwiftUI
import Charts
import SwiftData

struct ExpenseChartView: View {
    @Query private var expenses: [Expense]
    @AppStorage("currency") private var currency: String = "USD"
    
    /// ✅ Group expenses by category and calculate total per category
    var groupedExpenses: [(category: String, total: Double, percentage: Double)] {
        let totalAmount = expenses.reduce(0) { $0 + $1.amount }
        
        return Dictionary(grouping: expenses, by: { $0.category })
            .mapValues { $0.reduce(0) { $0 + $1.amount } }
            .map { category, total in
                let percentage = totalAmount > 0 ? (total / totalAmount) * 100 : 0
                return (category: category, total: total, percentage: percentage)
            }
            .sorted { $0.total > $1.total }
    }
    
    /// ✅ Compute total expense amount
    var totalAmount: Double {
        expenses.reduce(0) { $0 + $1.amount }
    }
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                let height = geometry.size.height
                
                VStack {
                    Text("Total: \(formatCurrency(totalAmount))")
                        .font(.title2)
                        .bold()
                        .padding(.bottom, 10)
                    
                    Chart {
                        ForEach(groupedExpenses, id: \.category) { data in
                            BarMark(
                                x: .value("Category", data.category),
                                y: .value("Total", data.total)
                            )
                            .foregroundStyle(by: .value("Category", data.category))
                            .annotation(position: .top) {
                                VStack {
                                    Text("\(data.percentage, specifier: "%.1f")%") // ✅ Show percentage
                                        .font(.caption)
                                        .bold()
                                    Text(formatCurrency(data.total)) // ✅ Show total amount
                                        .font(.caption)
                                }
                            }
                        }
                    }
                    .frame(height: height * 0.8)
                }
                .padding()
                .navigationTitle("Expense Breakdown")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency // Use selected currency
        formatter.currencySymbol = formatter.currencySymbol?.appending(" ") // ✅ Add space after the symbol
        return formatter.string(from: NSNumber(value: amount)) ?? "\(currency) \(amount)"
    }
}

#Preview {
    ExpenseChartView()
        .modelContainer(previewModelContainer)
}
