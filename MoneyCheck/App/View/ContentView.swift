//
//  ContentView.swift
//  MoneyCheck
//
//  Created by Максим Билык on 26.09.2024.
//

import SwiftUI
import Charts

struct ContentView: View {
    @State var selectedTab = "Home"
    let tabs = ["Home", "Report", "Settings", "Profile"]
    
    init() {
        UITabBar.appearance().isHidden = true
    }
    
    var body: some View {
        VStack {
            TabView(selection: $selectedTab) {
                MainView()
                    .tag("Home")
                ReportView()
                    .tag("Report")
                SettingsView()
                    .tag("Settings")
                Text("Profile")
                    .tag("Profile")
            }
            .edgesIgnoringSafeArea(.all)
            
            Spacer()
            
            HStack(spacing: 0) {
                ForEach(tabs, id: \.self) { tab in
                    TabBarItem(tab: tab, selected: $selectedTab)
                }
            }
            .padding(.bottom, 10)
            .frame(maxWidth: .infinity, minHeight: 60)
            .background(
                Color(UIColor.systemBackground) // Динамический цвет для фона
                    .shadow(color: Color.black.opacity(0.2), radius: 10)
            )
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct TabBarItem: View {
    let tab: String
    @Binding var selected: String
    
    var body: some View {
        ZStack {
            Button(action: {
                withAnimation(.easeInOut) {
                    selected = tab
                }
            }) {
                VStack {
                    Image(tab)
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 25, height: 25)
                        .foregroundColor(selected == tab ? Color.blue : Color.gray.opacity(0.7))
                    
                    Text(tab)
                        .font(.caption)
                        .foregroundColor(selected == tab ? Color.blue : Color.gray.opacity(0.7))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(selected == tab ? Color(UIColor.systemBackground) : Color.clear) // Динамическое изменение фона
                        .shadow(color: selected == tab ? Color.primary.opacity(0.1) : Color.clear, radius: 8, x: 0, y: 4)
                )
            }
        }
        .padding(.horizontal, 5)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ContentView()
}
