//
//  SpendingBreakdown.swift
//  MoneyCheck
//
//  Created by Максим Билык on 29.09.2024.
//
import SwiftUI

struct SpendingBreakdown: View {
    var expenses: [Expense]
    @Binding var selectedCategory: String?
    @Binding var showDetails: Bool
    
    var groupedExpenses: [String: Double] {
        Dictionary(grouping: expenses, by: { $0.category })
            .mapValues { $0.reduce(0) { $0 + $1.amount } }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Spending Breakdown")
                .font(.headline)
                .padding(.bottom, 10)
            
            ForEach(groupedExpenses.keys.sorted(), id: \.self) { category in
                HStack {
                    Text(category)
                        .font(.subheadline)
                    Spacer()
                    Text("$\(String(format: "%.2f", groupedExpenses[category]!))")
                        .foregroundColor(.red)
                }
                .padding(.vertical, 5)
                .onTapGesture {
                    selectedCategory = category
                    showDetails = true
                }
            }
        }
        .padding()
    }
}
