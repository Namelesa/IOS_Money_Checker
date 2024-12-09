import SwiftUI
import Charts

struct ReportView: View {
    @EnvironmentObject var transactionManager: TransactionViewModel
    @State private var selectedDate = Date()
    @State private var selectedCategory: String? = nil
    @State private var showCategoryDetails = false

    var filteredTransactions: [TransactionModel] {
        transactionManager.transactions.filter { $0.date.isSameDay(as: selectedDate) }
    }

    var groupedTransactions: [String: [TransactionModel]] {
        Dictionary(grouping: filteredTransactions, by: { $0.category })
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {

                    DatePicker("Choose the date", selection: $selectedDate, displayedComponents: [.date])
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .padding()

                    VStack(alignment: .leading) {
                        Text("Schedule of Income and Expenses")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        Chart {
                            ForEach(filteredTransactions) { transaction in
                                if transaction.amount.isFinite {
                                    BarMark(
                                        x: .value("Category", transaction.category),
                                        y: .value("Amount", transaction.amount)
                                    )
                                    .foregroundStyle(transaction.isIncome ? .green : .red)
                                }
                            }
                        }
                        .frame(height: 200)
                        .padding(.horizontal)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Categories")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(groupedTransactions.keys.sorted(), id: \.self) { category in
                            Button(action: {
                                selectedCategory = category
                                showCategoryDetails = true
                            }) {
                                HStack {
                                    Text(category)
                                        .font(.subheadline)
                                    Spacer()
                                    Text("$\(String(format: "%.2f", groupedTransactions[category]!.reduce(0) { $0 + $1.amount }))")
                                        .foregroundColor(.blue)
                                }
                                .padding(.vertical, 5)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Financial Review")
            .background(
                NavigationLink("", destination: CategoryDetailView(category: selectedCategory ?? "", transactions: filteredTransactions), isActive: $showCategoryDetails)
                    .hidden()
            )
        }
    }
}
