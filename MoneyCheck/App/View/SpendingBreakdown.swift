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
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Spending Breakdown")
                .font(.headline)
            
            ForEach(expenses, id: \.category) { expense in
                HStack {
                    Text(expense.category)
                    Spacer()
                    Text("$\(String(format: "%.2f", expense.amount))")
                        .foregroundColor(expense.isIncome ? .green : .red)
                }
                .onTapGesture {
                    selectedCategory = expense.category
                    showDetails.toggle()
                }
            }
        }
        .padding()
    }
}
