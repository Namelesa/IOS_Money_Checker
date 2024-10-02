//
//  ReportView.swift
//  MoneyCheck
//
//  Created by Максим Билык on 26.09.2024.
//
import SwiftUI
struct ReportView: View {
    @AppStorage("salary") private var salary: Double = 500.0
    @State private var expenses: [Expense] = [
        Expense(category: "Salary", amount: 500.0, isIncome: true, date: Date()),
        Expense(category: "Transport", amount: 100.0, isIncome: false, date: Date().addingTimeInterval(-86400 * 2)),
        Expense(category: "Dining", amount: 120.0, isIncome: false, date: Date().addingTimeInterval(-86400 * 3)),
        Expense(category: "Shopping", amount: 80.0, isIncome: false, date: Date().addingTimeInterval(-86400 * 10)),
    ]

    @State private var selectedCategory: String? = nil
    @State private var showDetails = false

    @State private var selectedMonth = Calendar.current.component(.month, from: Date())
    @State private var selectedYear = Calendar.current.component(.year, from: Date())

    var totalExpenses: Double {
        expenses.filter { !$0.isIncome && Calendar.current.component(.month, from: $0.date) == selectedMonth && Calendar.current.component(.year, from: $0.date) == selectedYear }.reduce(0) { $0 + $1.amount }
    }

    var totalIncome: Double {
        expenses.filter { $0.isIncome && Calendar.current.component(.month, from: $0.date) == selectedMonth && Calendar.current.component(.year, from: $0.date) == selectedYear }.reduce(0) { $0 + $1.amount }
    }

    var remainingMoney: Double {
        salary - totalExpenses
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Spent")
                            .font(.system(size: 18, weight: .semibold))
                        Text("$\(String(format: "%.0f", totalExpenses))")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.red)
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("Income")
                            .font(.system(size: 18, weight: .semibold))
                        Text("$\(String(format: "%.0f", totalIncome))")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.green)
                    }
                }
                .padding(.horizontal)

                Picker("Month", selection: $selectedMonth) {
                    ForEach(1...12, id: \.self) { month in
                        Text("\(month)").tag(month)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)

                SmoothLineGraph(expenses: expenses, selectedMonth: $selectedMonth, selectedYear: $selectedYear)
                    .frame(height: 200)
                    .padding(.horizontal)

                SpendingBreakdown(expenses: expenses, selectedCategory: $selectedCategory, showDetails: $showDetails)

                Spacer()
            }
            .padding()
        }
        .sheet(isPresented: $showDetails) {
            if let selectedCategory = selectedCategory {
                CategoryDetailView(category: selectedCategory, expenses: expenses)
            }
        }
    }
}

struct SmoothLineGraph: View {
    var expenses: [Expense]
    @Binding var selectedMonth: Int
    @Binding var selectedYear: Int

    var filteredExpenses: [Expense] {
        expenses.filter {
            Calendar.current.component(.month, from: $0.date) == selectedMonth &&
            Calendar.current.component(.year, from: $0.date) == selectedYear
        }
    }
    
    var body: some View {
        VStack {
            
            Rectangle()
                .fill(Color.blue.opacity(0.3))
                .frame(height: 200)
        }
    }
}

#Preview {
    ReportView()
}
