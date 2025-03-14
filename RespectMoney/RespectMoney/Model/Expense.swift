//
//  Expense.swift
//  RespectMoney
//
//  Created by Miguel Duran on 14-03-25.
//

import SwiftData
import Foundation

@Model
class Expense {
    var id: UUID
    var title: String
    var amount: Double
    var category: String
    var date: Date

    init(title: String, amount: Double, category: String, date: Date) {
        self.id = UUID()
        self.title = title
        self.amount = amount
        self.category = category
        self.date = date
    }
}
