//
//  UserEntity.swift
//  MoneyCheck
//
//  Created by Максим Билык on 12.12.2024.
//

import Foundation
import RealmSwift

class UserEntity: Object, Codable {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var name: String
    @Persisted var email: String
    @Persisted var lastSyncDate: Date
    @Persisted var nextSyncDate: Date
    @Persisted var isEmailVirefied: Bool
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
        self.email = model.email
    }
}
