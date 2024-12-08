//
//  AppDelegate.swift
//  MoneyCheck
//
//  Created by Dima Zanuda on 08.12.2024.
//

import UIKit
import RealmSwift

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        configMigration()
        return true
    }

    private func configMigration() {
        // perform migration if necessary
        let config = Realm.Configuration(
            schemaVersion: 2,
            migrationBlock: { migration, oldSchemaVersion in
                // additional process such as rename, combine fields, and link to other objects
            })
        Realm.Configuration.defaultConfiguration = config
    }
}

