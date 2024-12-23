//
//  User.swift
//  MoneyCheck
//
//  Created by Максим Билык on 12.12.2024.
//
import SwiftUI

struct User: Identifiable, Codable {
    let id: String
    let name: String
    let email: String
    let lastSyncDate: Date
}

extension User {
    init(entity: UserEntity) {
        self.id = entity.id
        self.name = entity.name
        self.email = entity.email
        self.lastSyncDate = entity.lastSyncDate
    }
}

