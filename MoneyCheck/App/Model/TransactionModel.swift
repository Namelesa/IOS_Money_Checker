//
//  TransactionModel.swift
//  MoneyCheck
//
//  Created by Максим Билык on 05.12.2024.
//
import SwiftUI

struct TransactionModel: Identifiable, Codable {
    let id: String
    let date: Date
    var categoryId: String
    var category: String
    let amount: Double
    let isIncome: Bool
}

extension TransactionModel {
    init(entity: TransactionEntity) {
        self.id = entity.id
        self.date = entity.date
        self.amount = entity.amount
        self.isIncome = entity.isIncome

        if let category = entity.category {
            self.categoryId = category.id
            self.category = category.name
        } else {
            self.categoryId = ""
            self.category = "Unknown"
        }
    }
}
