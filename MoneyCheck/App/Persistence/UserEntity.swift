//
//  UserEntity.swift
//  MoneyCheck
//
//  Created by Максим Билык on 12.12.2024.
//

import Foundation
import RealmSwift

class UserEntity: Object {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var name: String
    @Persisted var transactions = List<TransectionEntity>()
}

extension UserEntity {
    convenience init(model: User) {
        self.init()
        if let objectId = try? ObjectId(string: model.id) {
            self.id = objectId
        } else {
            self.id = ObjectId.generate()
        }
        self.name = model.name
    }
}
