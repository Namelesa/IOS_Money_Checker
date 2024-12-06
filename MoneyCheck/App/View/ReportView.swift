import SwiftUI
import Charts

struct ReportView: View {
    @State private var selectedDate = Date()
    @State private var selectedCategory: String? = nil
    @State private var showCategoryDetails = false
    
    @State private var transactions = [
        TransactionModel(date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, categoryId: 1, category: "Test1", amount: 450, isIncome: false),
        TransactionModel(date: Date(), categoryId: 2, category: "Test2", amount: 300, isIncome: false),
        TransactionModel(date: Date(), categoryId: 3, category: "Test3", amount: 150, isIncome: false),
        TransactionModel(date: Date(), categoryId: 4, category: "Test4", amount: 200, isIncome: false),
        TransactionModel(date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!, categoryId: 5, category: "Salary", amount: 5000, isIncome: true),
        TransactionModel(date: Date(), categoryId: 6, category: "Bonus", amount: 2000, isIncome: true)
    ]
    
    var filteredTransactions: [TransactionModel] {
        transactions.filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
    }
    
    var expenses: [TransactionModel] {
        filteredTransactions.filter { !$0.isIncome }
    }
    
    var incomes: [TransactionModel] {
        filteredTransactions.filter { $0.isIncome }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    DatePicker("Choose the date", selection: $selectedDate, displayedComponents: [.date])
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    
                    VStack(alignment: .leading) {
                        Text("Schedule of income and expenses")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        Chart {
                            ForEach(incomes) { income in
                                BarMark(
                                    x: .value("Source", income.category),
                                    y: .value("Amount", income.amount)
                                )
                                .foregroundStyle(.green)
                            }
                            
                            ForEach(expenses) { expense in
                                BarMark(
                                    x: .value("Category", expense.category),
                                    y: .value("Amount", expense.amount)
                                )
                                .foregroundStyle(.red)
                            }
                        }
                        .frame(height: 200)
                        .padding(.horizontal)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Expenses")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(expenses) { expense in
                            HStack {
                                Text(expense.category)
                                Spacer()
                                Text("\(expense.amount, specifier: "%.2f") $")
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 5)
                            .onTapGesture {
                                selectedCategory = expense.category
                                showCategoryDetails.toggle()
                            }
                        }
                    }
                    .padding(.top)

                    VStack(alignment: .leading) {
                        Text("Incomes")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(incomes) { income in
                            HStack {
                                Text(income.category)
                                Spacer()
                                Text("\(income.amount, specifier: "%.2f") $")
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 5)
                        }
                    }
                }
                .padding(.vertical)
            }
            .background(Color(UIColor.systemBackground))
            .navigationTitle("Financial Review")
            .navigationDestination(isPresented: $showCategoryDetails) {
                if let selectedCategory {
                    CategoryDetailView(category: selectedCategory, transactions: transactions)
                }
            }
        }
    }
}

struct ReportView_Previews: PreviewProvider {
    static var previews: some View {
        ReportView()
    }
}
