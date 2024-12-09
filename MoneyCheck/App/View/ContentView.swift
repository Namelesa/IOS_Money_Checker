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
    
    var body: some View {
        TabView(selection: $selectedTab) {
            MainView()
                .tag("Home")
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            
            ReportView()
                .tag("Report")
                .tabItem {
                    Label("Report", systemImage: "chart.bar")
                }
            
            Text("Settings")
                .tag("Settings")
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
            
            Text("Profile")
                .tag("Profile")
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(TransactionViewModel())
}
