//
//  ReportView.swift
//  MoneyCheck
//
//  Created by Максим Билык on 26.09.2024.
//

import SwiftUI

struct ReportView: View {
    @AppStorage("salary") private var salary: Double = 0
    @State private var expenses: [Expense] = [
        Expense(category: "Еда", amount: 150.0, isIncome: false),
        Expense(category: "Транспорт", amount: 50.0, isIncome: false),
        Expense(category: "Развлечения", amount: 75.0, isIncome: false)
    ]
    
    var totalExpenses: Double {
        expenses.reduce(0) { $0 + $1.amount }
    }
    
    var remainingMoney: Double {
        salary - totalExpenses
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false){
            VStack(spacing: 20) {
                Text("Ваши расходы")
                    .font(.largeTitle)
                    .padding()

                PieChart(expenses: expenses)
                    .frame(height: 300)

                Text("Всего потрачено: \(String(format: "%.2f", totalExpenses))")
                    .font(.title2)
                    .padding()

                Text("Остаток: \(String(format: "%.2f", remainingMoney))")
                    .font(.title2)
                    .padding()
            }
            .padding()
        }
    }
}
