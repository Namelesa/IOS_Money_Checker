//
//  TransctionEntity.swift
//  MoneyCheck
//
//  Created by Dima Zanuda on 08.12.2024.
//

import Foundation
import RealmSwift

class TransactionEntity: Object, Codable{
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var date: Date = Date()
    @Persisted var category: CategoryEntity!
    @Persisted var amount: Double
    @Persisted var isIncome: Bool
    @Persisted var isSync: Bool = false
}

extension TransactionEntity {
    convenience init(model: TransactionModel, categoryEntity: CategoryEntity) {
        self.init()
        guard let objectId = try? ObjectId(string: model.id) else {
            fatalError("Invalid ID format")
        }
        self.id = objectId
        self.date = model.date
        self.amount = model.amount
        self.isIncome = model.isIncome
        self.category = categoryEntity
    }
}
