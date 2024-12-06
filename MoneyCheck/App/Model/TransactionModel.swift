//
//  TransactionModel.swift
//  MoneyCheck
//
//  Created by Максим Билык on 05.12.2024.
//
import SwiftUI
import Charts

struct TransactionModel: Identifiable {
    let id = UUID()
    let date: Date
    var categoryId: Int
    var category: String
    let amount: Double
    let isIncome: Bool
}
