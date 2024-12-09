//
//  CategoryDetailView.swift
//  MoneyCheck
//
//  Created by Максим Билык on 29.09.2024.
//

import SwiftUI
import Charts

struct CategoryDetailView: View {
    let category: String
    let transactions: [TransactionModel]
    
    var filteredTransactions: [TransactionModel] {
        transactions.filter { $0.category == category }
    }

    var transactionsLastMonth: [TransactionModel] {
        let oneMonthAgo = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
        return filteredTransactions.filter { $0.date >= oneMonthAgo }
    }
    
    var incomeTransactions: [TransactionModel] {
        transactionsLastMonth.filter { $0.isIncome }
    }
    
    var expenseTransactions: [TransactionModel] {
        transactionsLastMonth.filter { !$0.isIncome }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Category Details: \(category)")
                .font(.title2)
                .bold()
                .padding(.horizontal)

            Chart {
                ForEach(incomeTransactions) { transaction in
                    BarMark(
                        x: .value("Date", transaction.date, unit: .day),
                        y: .value("Amount", transaction.amount)
                    )
                    .foregroundStyle(.green)
                }
                ForEach(expenseTransactions) { transaction in
                    BarMark(
                        x: .value("Date", transaction.date, unit: .day),
                        y: .value("Amount", transaction.amount)
                    )
                    .foregroundStyle(.red)
                }
            }
            .frame(height: 200)
            .padding(.horizontal)
            

            VStack(alignment: .leading) {
                Text("Income Transactions (Last Month)")
                    .font(.headline)
                    .padding(.horizontal)
                
                List(incomeTransactions) { transaction in
                    HStack {
                        Text(transaction.date, style: .date)
                        Spacer()
                        Text("\(transaction.amount, specifier: "%.2f") $")
                            .foregroundColor(.green)
                    }
                }
            }
            
            VStack(alignment: .leading) {
                Text("Expense Transactions (Last Month)")
                    .font(.headline)
                    .padding(.horizontal)
                
                List(expenseTransactions) { transaction in
                    HStack {
                        Text(transaction.date, style: .date)
                        Spacer()
                        Text("\(transaction.amount, specifier: "%.2f") $")
                            .foregroundColor(.red) 
                    }
                }
            }
        }
        .navigationTitle("\(category) Details")
        .padding()
    }
}
