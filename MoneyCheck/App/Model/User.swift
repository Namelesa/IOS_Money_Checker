//
//  User.swift
//  MoneyCheck
//
//  Created by Максим Билык on 12.12.2024.
//
import SwiftUI

struct User: Identifiable {
    let id: String
    let name: String
    let email: String
}

extension User {
    init(entity: UserEntity) {
        self.id = entity.id.stringValue
        self.name = entity.name
        self.email = entity.email
    }
}

