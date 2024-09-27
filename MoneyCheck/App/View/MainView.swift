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
    @State private var category: String = ""
    @State private var amount: String = ""
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 30) {
                Text("Your Budget")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .padding(.top, 40)
                    .shadow(radius: 10)
            
                VStack(spacing: 16) {
                    Text("Input Your Salary")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    TextField("Зарплата", value: $salary, format: .currency(code: "USD"))
                        .padding()
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(12)
                        .shadow(radius: 5)
                        .foregroundColor(.primary)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .shadow(radius: 5)
                        )
                        .keyboardType(.decimalPad)
                        .foregroundColor(.primary)
                }
                .padding(.horizontal)
                .padding(.vertical, 20)
                
                VStack(spacing: 16) {
                    Text("Add Transaction")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    TextField("Category", text: $category)
                        .padding()
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(12)
                        .shadow(radius: 5)
                        .foregroundColor(.primary)
                    
                    TextField("Sum", text: $amount)
                        .padding()
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(12)
                        .keyboardType(.decimalPad)
                        .shadow(radius: 5)
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 20) {
                        Button(action: {
                            if let amountValue = Double(amount), !category.isEmpty {
                                let newTransaction = Expense(category: category, amount: amountValue, isIncome: true)
                                transactions.append(newTransaction)
                                category = ""
                                amount = ""
                            }
                        }) {
                            Text("Income")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(15)
                                .shadow(radius: 5)
                        }

                        Button(action: {
                            if let amountValue = Double(amount), !category.isEmpty {
                                let newTransaction = Expense(category: category, amount: amountValue, isIncome: false)
                                transactions.append(newTransaction)
                                category = ""
                                amount = ""
                            }
                        }) {
                            Text("Expense")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(15)
                                .shadow(radius: 5)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 20)
                
                if !transactions.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Transaction History")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                            .padding(.horizontal)
                        
                        ForEach(transactions) { transaction in
                            HStack {
                                Text(transaction.category)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Spacer()
                                Text((transaction.isIncome ? "+" : "-") + String(format: "%.2f", transaction.amount))
                                    .font(.headline)
                                    .foregroundColor(transaction.isIncome ? .green : .red)
                            }
                            .padding()
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(12)
                            .shadow(radius: 5)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding()
        }
        .background(Color(UIColor.systemBackground))
    }
}

#Preview {
    MainView()
}
