//
//  AppDelegate.swift
//  MoneyCheck
//
//  Created by Dima Zanuda on 08.12.2024.
//

import UIKit
import RealmSwift
import UserNotifications

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {

        NotificationService.shared.requestAuthorization()
        
        configMigration()
                
        return true
    }

    private func configMigration() {
        let config = Realm.Configuration(
            schemaVersion: 3,
            migrationBlock: { migration, oldSchemaVersion in
            })
        Realm.Configuration.defaultConfiguration = config
    }
}
