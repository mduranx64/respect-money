//
//  MainTabView.swift
//  RespectMoney
//
//  Created by Miguel Duran on 14-03-25.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            TransactionListView()
                .tabItem {
                    Label("Expenses", systemImage: "list.bullet")
                }
            
            TransactionChartView()
                .tabItem {
                    Label("Insights", systemImage: "chart.bar.fill")
                }
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
    }
}

#Preview {
    MainTabView()
}
