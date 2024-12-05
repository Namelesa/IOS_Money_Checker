import SwiftUI
import Charts

struct ReportView: View {
    @State private var selectedDate = Date()
    @State private var selectedCategory: String? = nil
    @State private var showCategoryDetails = false
    
    @State private var expenses = [
        Expense(date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, category: "Test1", amount: 450),
        Expense(date: Date(), category: "Test2", amount: 300),
        Expense(date: Date(), category: "Test3", amount: 150),
        Expense(date: Date(), category: "Test4", amount: 200)
    ]
    
    @State private var incomes = [
        Income(date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!, source: "Salary", amount: 5000),
        Income(date: Date(), source: "Test5", amount: 2000)
    ]
    
    var filteredExpenses: [Expense] {
        expenses.filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
    }
    
    var filteredIncomes: [Income] {
        incomes.filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
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
                            ForEach(filteredIncomes) { income in
                                BarMark(
                                    x: .value("Source", income.source),
                                    y: .value("Price", income.amount)
                                )
                                .foregroundStyle(.green)
                            }
                            
                            ForEach(filteredExpenses) { expense in
                                BarMark(
                                    x: .value("Category", expense.category),
                                    y: .value("Price", expense.amount)
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
                        
                        ForEach(filteredExpenses) { expense in
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
                        
                        ForEach(filteredIncomes) { income in
                            HStack {
                                Text(income.source)
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
                    CategoryDetailView(category: selectedCategory, expenses: expenses)
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
