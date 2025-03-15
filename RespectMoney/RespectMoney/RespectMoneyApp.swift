//
//  RespectMoneyApp.swift
//  RespectMoney
//
//  Created by Miguel Duran on 13-03-25.
//

import SwiftUI
import SwiftData

@main
struct RespectMoneyApp: App {
    
    
    init () {
        setupDefaultData()
    }

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Expense.self,
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
        
        let defaultCategories = "Food,Transport,Shopping,Entertainment,Bills,Other"
        
        // ✅ Set default categories only on first launch
        if UserDefaults.standard.string(forKey: "categories") == nil {
            UserDefaults.standard.set(defaultCategories, forKey: "categories")
        }
        
        // ✅ Detect and set the local currency if not already set
        if UserDefaults.standard.string(forKey: "currency") == nil {
            let localCurrency = Locale.current.currency?.identifier ?? "USD" // Get system currency, fallback to USD
            UserDefaults.standard.set(localCurrency, forKey: "currency")
        }
    }
}
