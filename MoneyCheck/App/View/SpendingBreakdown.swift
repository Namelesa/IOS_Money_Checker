//
//  SpendingBreakdown.swift
//  MoneyCheck
//
//  Created by Максим Билык on 29.09.2024.
//
import SwiftUI

struct SpendingBreakdown: View {
    var transactions: [TransactionModel]
    @Binding var selectedCategory: String?
    @Binding var showDetails: Bool
    
    var groupedTransactions: [String: Double] {
        Dictionary(grouping: transactions, by: { $0.category })
            .mapValues { $0.reduce(0) { $0 + $1.amount } }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Spending Breakdown")
                .font(.headline)
                .padding(.bottom, 10)
            
            ForEach(groupedTransactions.keys.sorted(), id: \.self) { category in
                HStack {
                    Text(category)
                        .font(.subheadline)
                    Spacer()
                    Text("$\(String(format: "%.2f", groupedTransactions[category]!))")
                        .foregroundColor(groupedTransactions[category]! < 0 ? .red : .green)
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

#Preview {
    SpendingBreakdown(
        transactions: [
//            TransactionModel(date: Date(), categoryId: 1, category: "Food", amount: -50, isIncome: false),
//            TransactionModel(date: Date(), categoryId: 2, category: "Transport", amount: -20, isIncome: false),
//            TransactionModel(date: Date(), categoryId: 1, category: "Food", amount: -30, isIncome: false),
//            TransactionModel(date: Date(), categoryId: 3, category: "Salary", amount: 1500, isIncome: true)
        ],
        selectedCategory: .constant(nil),
        showDetails: .constant(false)
    )
}
