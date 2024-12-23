//
//  CategoryEntity.swift
//  MoneyCheck
//
//  Created by Dima Zanuda on 08.12.2024.
//

import Foundation
import RealmSwift

class CategoryEntity: Object, Codable {
    @Persisted(primaryKey: true) var id: String
    @Persisted var name: String
    @Persisted var transactions = List<TransactionEntity>()
    @Persisted var user: UserEntity!
    
}

extension CategoryEntity {
    convenience init(id: String, name: String, userEntity: UserEntity) {
        self.init()
        self.id = id
        self.name = name
        self.user = userEntity
    }
}
