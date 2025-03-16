//
//  RespectMoneyApp.swift
//  RespectMoney
//
//  Created by Miguel Duran on 13-03-25.
//

import SwiftUI
import SwiftData

enum TransactionType: String, CaseIterable {
    case expense = "Expense"
    case income = "Income"
}

let transactionTypes = TransactionType.allCases.map(\.rawValue)

@main
struct RespectMoneyApp: App {
    
    
    init () {
        setupDefaultData()
    }

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Transaction.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(sharedModelContainer)
    }
    
    private func setupDefaultData() {
        
        let defaultExpenseCategories = "Food,Transport,Shopping,Entertainment,Bills,Other"
        let defaultIncomeCategories = "Salary,Other"
        
        if UserDefaults.standard.string(forKey: "expenseCategories") == nil {
            UserDefaults.standard.set(defaultExpenseCategories, forKey: "expenseCategories")
        }
        
        if UserDefaults.standard.string(forKey: "incomeCategories") == nil {
            UserDefaults.standard.set(defaultIncomeCategories, forKey: "incomeCategories")
        }
        
        if UserDefaults.standard.string(forKey: "currency") == nil {
            let localCurrency = Locale.current.currency?.identifier ?? "USD" // Get system currency, fallback to USD
            UserDefaults.standard.set(localCurrency, forKey: "currency")
        }
    }
}
