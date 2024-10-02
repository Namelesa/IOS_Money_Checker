//
//  SpendingBreakdown.swift
//  MoneyCheck
//
//  Created by Максим Билык on 29.09.2024.
//
import SwiftUI

struct SpendingBreakdown: View {
    let expenses: [Expense]
    @Binding var selectedCategory: String?
    @Binding var showDetails: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Spending Breakdown")
                .font(.system(size: 18, weight: .semibold))
                .padding(.vertical, 10)

            let categories = Array(Set(expenses.map { $0.category }))
            
            ForEach(categories, id: \.self) { category in
                let categoryExpenses = expenses.filter { $0.category == category }
                let totalAmount = categoryExpenses.reduce(0) { $0 + $1.amount }
                
                Button(action: {
                    selectedCategory = category
                    showDetails = true
                }) {
                    HStack {
                        Text(category)
                            .font(.system(size: 16))
                        Spacer()
                        Text("$\(String(format: "%.0f", totalAmount))")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 5)
                }
            }
        }
        .padding(.horizontal)
    }
}
