//
//  PieChart.swift
//  MoneyCheck
//
//  Created by Максим Билык on 26.09.2024.
//

import SwiftUI
import Charts

struct PieChart: View {
    let expenses: [Expense]
    
    var body: some View {
        Chart(expenses) { expense in
            SectorMark(
                angle: .value("Сумма", expense.amount),
                innerRadius: .ratio(0.5)
            )
            .foregroundStyle(by: .value("Категория", expense.category))
        }
    }
}
