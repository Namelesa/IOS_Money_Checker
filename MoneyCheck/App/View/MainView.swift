import SwiftUI

struct MainView: View {
    @EnvironmentObject var transactionManager: TransactionViewModel
    @EnvironmentObject var categoryManager: CategoryViewModel
    @State private var transactions: [TransactionModel] = []
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
                    transactionInputSection
                    transactionBreakdownSection
                }
                .padding()
            }
            .navigationTitle("MoneyCheck")
            .onAppear {
                transactionManager.fetchTransactions()
            }
        }
    }

    private var transactionInputSection: some View {
        VStack(spacing: 15) {
            Text("Add Transaction")
                .font(.headline)

            VStack(alignment: .leading, spacing: 10) {
                Text("Category:")
                    .font(.subheadline)
                HStack {
                    TextField("New or existing category", text: $category)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    Picker("", selection: $category) {
                        Text("Select Category").tag("")
                        ForEach(categoryManager.categories) { category in
                            Text(category.name).tag(category.name)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("Amount:")
                    .font(.subheadline)
                TextField("Enter amount", text: $amount)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.decimalPad)
            }

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
    }

    private var transactionBreakdownSection: some View {
        SpendingBreakdown(transactionManager: transactionManager, selectedCategory: $selectedCategory, showDetails: $showDetails)
    }

    private func addTransaction(isIncome: Bool) {
        guard let amountValue = Double(amount), !category.isEmpty else {
            print("Invalid input")
            return
        }

        var categoryObject: Category? = categoryManager.categories.first(where: { $0.name == category })

        if categoryObject == nil {
            categoryManager.createCategory(name: category)
            categoryObject = categoryManager.categories.first(where: { $0.name == category })
        }

        guard let validCategory = categoryObject else {
            print("Category not found")
            return
        }

        transactionManager.createTransaction(date: Date.now, amount: amountValue, isIncome: isIncome, categoryId: validCategory.id)

        amount = ""
        category = ""
    }
}
