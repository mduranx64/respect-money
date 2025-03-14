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
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Expense.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)

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
}
