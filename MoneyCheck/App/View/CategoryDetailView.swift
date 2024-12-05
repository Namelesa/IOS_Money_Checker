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
    let expenses: [Expense]
    
    var filteredExpenses: [Expense] {
        expenses.filter { $0.category == category }
    }
    
    var dailyTotal: Double {
        filterExpenses(for: .day)
    }
    
    var weeklyTotal: Double {
        filterExpenses(for: .weekOfYear)
    }
    
    var monthlyTotal: Double {
        filterExpenses(for: .month)
    }
    
    var yearlyTotal: Double {
        filterExpenses(for: .year)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Category Details: \(category)")
                .font(.title2)
                .bold()
                .padding(.horizontal)
            
            // График
            Chart {
                ForEach(filteredExpenses) { expense in
                    BarMark(
                        x: .value("Date", expense.date, unit: .day),
                        y: .value("Amount", expense.amount)
                    )
                    .foregroundStyle(.red)
                }
            }
            .frame(height: 200)
            .padding(.horizontal)
            
            // Сводка
            List {
                Section(header: Text("Summary")) {
                    summaryRow(title: "Daily Total", amount: dailyTotal)
                    summaryRow(title: "Weekly Total", amount: weeklyTotal)
                    summaryRow(title: "Monthly Total", amount: monthlyTotal)
                    summaryRow(title: "Yearly Total", amount: yearlyTotal)
                }
                
                Section(header: Text("Expenses")) {
                    ForEach(filteredExpenses) { expense in
                        HStack {
                            Text(expense.date, style: .date)
                            Spacer()
                            Text("$\(String(format: "%.2f", expense.amount))")
                        }
                    }
                }
            }
            .listStyle(GroupedListStyle())
        }
        .navigationTitle("\(category) Details")
        .padding()
    }
    
    func filterExpenses(for component: Calendar.Component) -> Double {
        let calendar = Calendar.current
        let today = Date()
        return filteredExpenses
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

#Preview {
    CategoryDetailView(category: "Dining", expenses: [
        Expense(date: Date().addingTimeInterval(-86400), category: "Dining", amount: 20),
        Expense(date: Date().addingTimeInterval(-86400 * 7), category: "Dining", amount: 50),
        Expense(date: Date().addingTimeInterval(-86400 * 30), category: "Dining", amount: 100)
    ])
}
