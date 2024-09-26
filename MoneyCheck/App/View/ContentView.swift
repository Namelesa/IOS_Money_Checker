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
        
        ZStack(alignment: .bottom){
            TabView(selection: $selectedTab){
                MainView()
                    .tag("Home")
                ReportView()
                    .tag("Report")
                SettingsView()
                    .tag("Settings")
                Text("Profile")
                    .tag("Profile")
            }
            HStack{
                ForEach(tabs, id: \.self){ tab in
                    TabBarItem(tab: tab, selected: $selectedTab)
                }
            }
            .padding(.bottom, 5)
            .padding(.top, 20)
            .frame(maxWidth: .infinity)
            .background(Color("MainBg"))
        }
    }
}

struct TabBarItem: View{
    @State var tab : String
    @Binding var selected: String
    var body: some View {
        ZStack{
            Button{
                withAnimation(.spring()){
                    selected = tab
                }
                
            } label: {
                HStack{
                    Image(tab)
                        .resizable()
                        .frame(width: 20, height: 20)
                }
            }
        }
        .opacity(selected == tab ? 1 : 0.7)
        .padding(.vertical, 10)
        .padding(.horizontal, 27)
        .background(selected == tab ? .white : Color("MainBg"))
        .clipShape(Capsule())
    }
}

#Preview {
    ContentView()
}
