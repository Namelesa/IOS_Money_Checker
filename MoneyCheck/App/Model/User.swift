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
}

extension Category {
    init(entity: UserEntity) {
        self.id = entity.id.stringValue
        self.name = entity.name
    }
}

