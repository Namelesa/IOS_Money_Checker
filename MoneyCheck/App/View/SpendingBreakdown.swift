//
//  SpendingBreakdown.swift
//  MoneyCheck
//
//  Created by Максим Билык on 29.09.2024.
//
import SwiftUI

struct SpendingBreakdown: View {
    @ObservedObject var transactionManager: TransactionViewModel
    @Binding var selectedCategory: String?
    @Binding var showDetails: Bool
    var n: Int = 5 // Количество транзакций для отображения, по умолчанию 5
    
    var sortedTransactions: [TransactionModel] {
        transactionManager.transactions.sorted { $0.date > $1.date }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Spending Breakdown")
                .font(.headline)
                .padding(.bottom, 10)

            ForEach(sortedTransactions.prefix(n), id: \.id) { transaction in
                HStack {
                    Text(transaction.category)
                        .font(.subheadline)
                    Spacer()

                    Text("$\(String(format: "%.2f", abs(transaction.amount)))")
                        .foregroundColor(transaction.isIncome ? .green : .red) 
                }
                .padding(.vertical, 5)
                .onTapGesture {
                    selectedCategory = transaction.category
                    showDetails = true
                }
            }
        }
        .padding()
    }
}
