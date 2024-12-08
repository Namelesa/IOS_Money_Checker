//
//  TransactionModel.swift
//  MoneyCheck
//
//  Created by Максим Билык on 05.12.2024.
//
import SwiftUI

struct TransactionModel: Identifiable {
    let id: String
    let date: Date
    var categoryId: String
    var category: String
    let amount: Double
    let isIncome: Bool
}

extension TransactionModel {
    init(entity: TransectionEntity) {
        self.id = entity.id.stringValue
        self.date = entity.date
        self.categoryId = entity.category.id.stringValue
        self.category = entity.category.name
        self.amount = entity.amount
        self.isIncome = entity.isIncome
    }
}
