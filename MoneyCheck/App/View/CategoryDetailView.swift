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
    
    var dailyTotal: Double {
        filterTransactions(for: .day)
    }
    
    var weeklyTotal: Double {
        filterTransactions(for: .weekOfYear)
    }
    
    var monthlyTotal: Double {
        filterTransactions(for: .month)
    }
    
    var yearlyTotal: Double {
        filterTransactions(for: .year)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Category Details: \(category)")
                .font(.title2)
                .bold()
                .padding(.horizontal)
            
            // Chart for showing the transactions for the category
            Chart {
                ForEach(filteredTransactions) { transaction in
                    BarMark(
                        x: .value("Date", transaction.date, unit: .day),
                        y: .value("Amount", transaction.amount)
                    )
                    .foregroundStyle(transaction.isIncome ? .green : .red)
                }
            }
            .frame(height: 200)
            .padding(.horizontal)
            
            // Summary of total amounts
            List {
                Section(header: Text("Summary")) {
                    summaryRow(title: "Daily Total", amount: dailyTotal)
                    summaryRow(title: "Weekly Total", amount: weeklyTotal)
                    summaryRow(title: "Monthly Total", amount: monthlyTotal)
                    summaryRow(title: "Yearly Total", amount: yearlyTotal)
                }
                
                Section(header: Text("Transactions")) {
                    ForEach(filteredTransactions) { transaction in
                        HStack {
                            Text(transaction.date, style: .date)
                            Spacer()
                            Text("$\(String(format: "%.2f", transaction.amount))")
                        }
                    }
                }
            }
            .listStyle(GroupedListStyle())
        }
        .navigationTitle("\(category) Details")
        .padding()
    }
    
    func filterTransactions(for component: Calendar.Component) -> Double {
        let calendar = Calendar.current
        let today = Date()
        return filteredTransactions
            .filter {
                calendar.isDate($0.date, equalTo: today, toGranularity: component)
            }
            .reduce(0) { $0 + $1.amount }
    }
    
    private func summaryRow(title: String, amount: Double) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text("$\(String(format: "%.2f", amount))")
                .bold()
        }
        .padding(.vertical, 5)
    }
}

//#Preview {
//    CategoryDetailView(category: "Dining", transactions: [
//        TransactionModel(date: Date().addingTimeInterval(-86400), categoryId: 1, category: "Dining", amount: 20, isIncome: false),
//        TransactionModel(date: Date().addingTimeInterval(-86400 * 7), categoryId: 2, category: "Dining", amount: 50, isIncome: false),
//        TransactionModel(date: Date().addingTimeInterval(-86400 * 30), categoryId: 3, category: "Dining", amount: 100, isIncome: false)
//    ])
//}
