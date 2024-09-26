//
//  Expense.swift
//  MoneyCheck
//
//  Created by Максим Билык on 26.09.2024.
//

import SwiftUI
import Charts

struct Expense: Identifiable {
    let id = UUID()
    let category: String
    let amount: Double
}
