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
    @State private var selectedDate = Date() // Текущая дата

    var totalExpenses: Double {
        expenses.filter {
            !$0.isIncome && Calendar.current.isDate($0.date, equalTo: selectedDate, toGranularity: .month)
        }.reduce(0) { $0 + $1.amount }
    }

    var totalIncome: Double {
        expenses.filter {
            $0.isIncome && Calendar.current.isDate($0.date, equalTo: selectedDate, toGranularity: .month)
        }.reduce(0) { $0 + $1.amount }
    }

    var remainingMoney: Double {
        salary - totalExpenses
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) { // Добавляем отступы между элементами
                // Блок с доходами и расходами
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

                // Уменьшенный календарь
                DatePicker("Select Month", selection: $selectedDate, displayedComponents: [.date])
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .frame(maxHeight: 200) // Уменьшенная высота календаря
                    .padding()

                // График с увеличенной высотой
                SmoothLineGraph(expenses: expenses, selectedDate: $selectedDate)
                    .frame(height: 300) // Увеличиваем размер графика
                    .padding(.horizontal)

                // Разделение по категориям
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
    @Binding var selectedDate: Date

    var filteredExpenses: [Expense] {
        expenses.filter {
            Calendar.current.isDate($0.date, equalTo: selectedDate, toGranularity: .month)
        }
    }

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height

            // Количество дней в месяце
            let daysInMonth = Calendar.current.range(of: .day, in: .month, for: selectedDate)?.count ?? 30

            // Подготовка данных для отрисовки точек
            let points = filteredExpenses.map { expense -> CGPoint in
                let day = Calendar.current.component(.day, from: expense.date)
                let x = width * CGFloat(day) / CGFloat(daysInMonth)
                let y = height * (1 - CGFloat(expense.amount) / 1000) // Нормализуем сумму
                return CGPoint(x: x, y: y)
            }

            // Отрисовка линий
            Path { path in
                if let firstPoint = points.first {
                    path.move(to: firstPoint)

                    for point in points.dropFirst() {
                        path.addLine(to: point)
                    }
                }
            }
            .stroke(Color.blue, lineWidth: 2)
        }
        .frame(height: 300) // Высота графика
    }
}


#Preview {
    ReportView()
}
