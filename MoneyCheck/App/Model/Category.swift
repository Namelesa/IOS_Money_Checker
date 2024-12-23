//
//  Category.swift
//  MoneyCheck
//
//  Created by Максим Билык on 29.09.2024.
//

import SwiftUI

struct Category: Identifiable {
    let id: String
    let name: String
}

extension Category {
    init(entity: CategoryEntity) {
        self.id = entity.id
        self.name = entity.name
    }
}
