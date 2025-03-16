//
//  PreviewModelContainer.swift
//  RespectMoney
//
//  Created by Miguel Duran on 14-03-25.
//

import Foundation
import SwiftData

@MainActor
let previewModelContainer: ModelContainer = {
    do {
        // Create an in-memory SwiftData container
        let container = try ModelContainer(for: Transaction.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))

        // Insert mock transactions
        let context = ModelContext(container)
        context.insert(Transaction(title: "Groceries", amount: 50.0, category: "Food", date: Date(), type: TransactionType.expense.rawValue))
        context.insert(Transaction(title: "Uber", amount: 20.0, category: "Transport", date: Date(), type: TransactionType.expense.rawValue))
                       context.insert(Transaction(title: "Movies", amount: 15.0, category: "Entertainment", date: Date(), type: TransactionType.expense.rawValue))
        context.insert(Transaction(title: "Coffee", amount: 5.0, category: "Food", date: Date(), type: TransactionType.expense.rawValue))

        return container
    } catch {
        fatalError("Failed to create preview: \(error.localizedDescription)")
    }
}()
