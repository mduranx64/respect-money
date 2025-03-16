//
//  Transaction.swift
//  RespectMoney
//
//  Created by Miguel Duran on 14-03-25.
//

import SwiftData
import Foundation

@Model
class Transaction {
    var id: UUID
    var title: String
    var amount: Double
    var category: String
    var date: Date
    var type: String

    init(title: String, amount: Double, category: String, date: Date, type: String) {
        self.id = UUID()
        self.title = title
        self.amount = amount
        self.category = category
        self.date = date
        self.type = type
    }
}
