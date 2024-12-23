//
//  UserEntity.swift
//  MoneyCheck
//
//  Created by Максим Билык on 12.12.2024.
//

import Foundation
import RealmSwift

class UserEntity: Object, Codable {
    @Persisted(primaryKey: true) var id: String
    @Persisted var name: String
    @Persisted var email: String
    @Persisted var lastSyncDate: Date
    @Persisted var nextSyncDate: Date
    @Persisted var isEmailVirefied: Bool
    @Persisted var transactions = List<TransactionEntity>()
    @Persisted var categories = List<CategoryEntity>()
}

extension UserEntity {
    convenience init(model: User) {
        self.init()
        self.id = model.id
        self.name = model.name
        self.email = model.email
        self.lastSyncDate = model.lastSyncDate
    }
}
