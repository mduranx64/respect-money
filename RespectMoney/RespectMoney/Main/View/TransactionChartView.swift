//
//  TransactionChartView.swift
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

struct TransactionChartView: View {
    @Query private var transaction: [Transaction]
    @AppStorage("currency") private var currency: String = "USD"
    
    /// ✅ Group transaction by category and calculate total per category
    var groupedTransactions: [(category: String, total: Double, percentage: Double)] {
        let totalAmount = transaction.reduce(0) { $0 + $1.amount }
        
        return Dictionary(grouping: transaction, by: { $0.category })
            .mapValues { $0.reduce(0) { $0 + $1.amount } }
            .map { category, total in
                let percentage = totalAmount > 0 ? (total / totalAmount) * 100 : 0
                return (category: category, total: total, percentage: percentage)
            }
            .sorted { $0.total > $1.total }
    }
    
    /// ✅ Compute total expense amount
    var totalAmount: Double {
        transaction.reduce(0) { $0 + $1.amount }
    }
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                
                VStack {
                    Text("Total: \(totalAmount.formattedAsCurrency(currency))")
                        .font(.title2)
                        .bold()
                        .padding(.bottom, 10)
                    ScrollView(.horizontal) {
                        Chart {
                            ForEach(groupedTransactions, id: \.category) { data in
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
                                        Text(data.total.formattedAsCurrency(currency)) // ✅ Show total amount
                                            .font(.caption)
                                    }
                                }
                            }
                        }
                        .frame(minWidth: max(geometry.size.width, CGFloat(groupedTransactions.count) * 60))
                    }
                }
                .padding()
                .navigationTitle("Expenses Breakdown")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

#Preview {
    TransactionChartView()
        .modelContainer(previewModelContainer)
}
