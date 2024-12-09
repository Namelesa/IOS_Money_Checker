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
    @StateObject private var transactionManager = TransactionViewModel()
    @StateObject private var categoryManager = CategoryViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(transactionManager)
                .environmentObject(categoryManager) 
        }
    }
}

