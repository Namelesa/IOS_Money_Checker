//
//  MoneyCheckApp.swift
//  MoneyCheck
//
//  Created by Максим Билык on 21.09.2024.
//

import SwiftUI

@main
struct MoneyCheckApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(transactionManager)
        }
    }
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var transactionManager = TransactionViewModel()
    

}
