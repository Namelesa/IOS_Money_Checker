//
//  MoneyCheckApp.swift
//  MoneyCheck
//
//  Created by Максим Билык on 21.09.2024.
//
import SwiftUI

@main
struct MoneyCheckApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    private let container = DependencyContainer.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(container.transactionManager)
                .environmentObject(container.categoryManager)
                .environmentObject(container.userManager)
                .environmentObject(container.authManager)
        }
    }
}

