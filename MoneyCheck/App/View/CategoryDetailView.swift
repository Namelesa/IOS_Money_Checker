//
//  CategoryDetailView.swift
//  MoneyCheck
//
//  Created by Максим Билык on 29.09.2024.
//

import SwiftUI

struct CategoryDetailView: View {
    let category: String
    let expenses: [Expense]
    
    var dailyExpenses: [Expense] {
        expenses.filter { $0.category == category && !$0.isIncome }
    }
    
    var weeklyExpenses: Double {
        filterExpenses(for: .weekOfYear)
    }
    
    var monthlyExpenses: Double {
        filterExpenses(for: .month)
    }
    
    var yearlyExpenses: Double {
        filterExpenses(for: .year)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Details for \(category)")
                .font(.title)
                .padding()
            
            List {
                Section(header: Text("Expenses by Day")) {
                    ForEach(dailyExpenses, id: \.id) { expense in
                        HStack {
                            Text(expense.date, style: .date)
                            Spacer()
                            Text("$\(String(format: "%.2f", expense.amount))")
                        }
                    }
                }
                
                Section(header: Text("Summary")) {
                    HStack {
                        Text("Weekly Total:")
                        Spacer()
                        Text("$\(String(format: "%.2f", weeklyExpenses))")
                    }
                    HStack {
                        Text("Monthly Total:")
                        Spacer()
                        Text("$\(String(format: "%.2f", monthlyExpenses))")
                    }
                    HStack {
                        Text("Yearly Total:")
                        Spacer()
                        Text("$\(String(format: "%.2f", yearlyExpenses))")
                    }
                }
            }
            .listStyle(GroupedListStyle())
        }
        .padding()
    }
    
    func filterExpenses(for component: Calendar.Component) -> Double {
        let calendar = Calendar.current
        let today = Date()
        return dailyExpenses
            .filter { calendar.component(component, from: $0.date) == calendar.component(component, from: today) }
            .reduce(0) { $0 + $1.amount }
    }
}

#Preview {
    CategoryDetailView(category: "Dining", expenses: [
        Expense(category: "Dining", amount: 20.0, isIncome: false, date: Date().addingTimeInterval(-86400 * 1)),
        Expense(category: "Dining", amount: 50.0, isIncome: false, date: Date().addingTimeInterval(-86400 * 10)),
        Expense(category: "Dining", amount: 100.0, isIncome: false, date: Date().addingTimeInterval(-86400 * 30))
    ])
}
