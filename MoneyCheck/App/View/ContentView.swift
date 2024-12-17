//
//  ContentView.swift
//  MoneyCheck
//
//  Created by Максим Билык on 26.09.2024.
//

import Charts
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var transactionManager: TransactionViewModel
    @State private var selectedTab = "Home"
    @State private var transactionCount = 5
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false

    var body: some View {
        TabView(selection: $selectedTab) {
            if isLoggedIn {
                MainView(transactionCount: $transactionCount)
                    .tag("Home")
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }

                ReportView()
                    .tag("Report")
                    .tabItem {
                        Label("Report", systemImage: "chart.bar")
                    }

                SettingsView(transactionCount: $transactionCount)
                    .tag("Settings")
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }

                Profile()
                    .tag("Profile")
                    .tabItem {
                        Label("Profile", systemImage: "person")
                    }
                   } else {
                       AuthView(isLoggedIn: $isLoggedIn)
                   }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(TransactionViewModel())
}
