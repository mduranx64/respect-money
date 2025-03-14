//
//  ExpenseChartView.swift
//  RespectMoney
//
//  Created by Miguel Duran on 14-03-25.
//

import SwiftUI
import Charts
import SwiftData

struct ExpenseChartView: View {
    @Query private var expenses: [Expense]

    var groupedExpenses: [String: Double] {
        Dictionary(grouping: expenses, by: { $0.category })
            .mapValues { $0.reduce(0) { $0 + $1.amount } }
    }

    var body: some View {
        VStack {
            Text("Expense Breakdown")
                .font(.headline)
            
            Chart {
                ForEach(groupedExpenses.sorted(by: { $0.value > $1.value }), id: \.key) { category, total in
                    BarMark(
                        x: .value("Category", category),
                        y: .value("Total", total)
                    )
                    .foregroundStyle(by: .value("Category", category))
                }
            }
            .frame(height: 300)
        }
        .padding()
    }
}
