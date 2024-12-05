//
//  MainView.swift
//  MoneyCheck
//
//  Created by Максим Билык on 26.09.2024.
//

import SwiftUI

struct MainView: View {
    @AppStorage("salary") private var salary: Double = 0
    @State private var transactions: [Expense] = []
    @State private var selectedCategory: String? = nil
    @State private var showDetails = false
    @State private var category: String = ""
    @State private var amount: String = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    Text("Your Budget")
                        .font(.largeTitle)
                        .bold()

                    VStack {
                        Text("Input Your Salary")
                            .font(.headline)
                        TextField("Salary", value: $salary, format: .currency(code: "USD"))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.decimalPad)
                    }
                    .padding()

                    VStack {
                        Text("Add Transaction")
                            .font(.headline)
                        TextField("Category", text: $category)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        TextField("Amount", text: $amount)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.decimalPad)
                        HStack {
                            Button("Income") {
                                addTransaction(isIncome: true)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.green)
                            
                            Button("Expense") {
                                addTransaction(isIncome: false)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.red)
                        }
                    }
                    .padding()
                    
                    SpendingBreakdown(expenses: transactions, selectedCategory: $selectedCategory, showDetails: $showDetails)
                        .background(
                            NavigationLink("", destination: CategoryDetailView(category: selectedCategory ?? "", expenses: transactions), isActive: $showDetails)
                                .hidden()
                        )
                }
                .padding()
            }
            .navigationTitle("MoneyCheck")
        }
    }
    
    private func addTransaction(isIncome: Bool) {
        guard let amountValue = Double(amount), !category.isEmpty else { return }
        let transaction = Expense(date: Date(), category: category, amount: isIncome ? amountValue : -amountValue)
        transactions.append(transaction)
        category = ""
        amount = ""
    }
}

#Preview {
    MainView()
}
