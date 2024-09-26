//
//  MainView.swift
//  MoneyCheck
//
//  Created by Максим Билык on 26.09.2024.
//

import SwiftUI

struct MainView: View {
    @AppStorage("salary") private var salary: Double = 0
    @State private var expenses: [Expense] = []
    @State private var category: String = ""
    @State private var amount: String = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Ваш бюджет")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 20)

                VStack(alignment: .leading) {
                    Text("Введите вашу зарплату")
                        .font(.headline)
                    
                    HStack {
                        TextField("Зарплата", value: $salary, format: .currency(code: "USD"))
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .keyboardType(.decimalPad)
                    }
                }
                .padding(.horizontal)

                VStack(alignment: .leading) {
                    Text("Добавить расход")
                        .font(.headline)

                    TextField("Категория", text: $category)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    
                    TextField("Сумма", text: $amount)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .keyboardType(.decimalPad)
                }
                .padding(.horizontal)

                Button(action: {
                    if let amountValue = Double(amount), !category.isEmpty {
                        let newExpense = Expense(category: category, amount: amountValue)
                        expenses.append(newExpense)
                        category = ""
                        amount = ""
                    }
                }) {
                    Text("Добавить расход")
                        .font(.title2)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)

                List(expenses) { expense in
                    HStack {
                        Text(expense.category)
                        Spacer()
                        Text(String(format: "%.2f", expense.amount))
                    }
                }
            }
            .padding()
        }
        
    }
}
