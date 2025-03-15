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
        let container = try ModelContainer(for: Expense.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))

        // Insert mock expenses
        let context = ModelContext(container)
        context.insert(Expense(title: "Groceries", amount: 50.0, category: "Food", date: Date()))
        context.insert(Expense(title: "Uber", amount: 20.0, category: "Transport", date: Date()))
        context.insert(Expense(title: "Movies", amount: 15.0, category: "Entertainment", date: Date()))
        context.insert(Expense(title: "Coffee", amount: 5.0, category: "Food", date: Date()))

        return container
    } catch {
        fatalError("Failed to create preview: \(error.localizedDescription)")
    }
}()
