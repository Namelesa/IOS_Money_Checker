//
//  TransctionEntity.swift
//  MoneyCheck
//
//  Created by Dima Zanuda on 08.12.2024.
//

import Foundation
import RealmSwift

class TransactionEntity: Object, Codable{
    @Persisted(primaryKey: true) var id: String
    @Persisted var date: Date = Date()
    @Persisted var category: CategoryEntity!
    @Persisted var user: UserEntity!
    @Persisted var amount: Double
    @Persisted var isIncome: Bool
    @Persisted var isSync: Bool = false
}

extension TransactionEntity {
    convenience init(model: TransactionModel, categoryEntity: CategoryEntity, userEntity: UserEntity) {
        self.init()
        self.id = model.id
        self.date = model.date
        self.amount = model.amount
        self.isIncome = model.isIncome
        self.category = categoryEntity
        self.user = userEntity
    }
}
