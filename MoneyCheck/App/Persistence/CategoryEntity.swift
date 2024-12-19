//
//  CategoryEntity.swift
//  MoneyCheck
//
//  Created by Dima Zanuda on 08.12.2024.
//

import Foundation
import RealmSwift

class CategoryEntity: Object, Codable {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var name: String
    @Persisted var transactions = List<TransactionEntity>()
}

extension CategoryEntity {
    convenience init(model: Category) {
        self.init()
        if let objectId = try? ObjectId(string: model.id) {
            self.id = objectId
        } else {
            self.id = ObjectId.generate()
        }
        self.name = model.name
    }
}
