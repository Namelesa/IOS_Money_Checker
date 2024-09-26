//
//  ContentView.swift
//  MoneyCheck
//
//  Created by Максим Билык on 26.09.2024.
//

import SwiftUI
import Charts

struct ContentView: View {
    var body: some View {
        TabView {
            MainView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }

            ReportView()
                .tabItem {
                    Image(systemName: "chart.pie.fill")
                    Text("Statistics")
                }

            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
        }
        .onAppear {
            NotificationManager.shared.requestAuthorization()
            NotificationManager.shared.scheduleMonthlyReminder()
        }
    }
}

// Модель для категории расхода
struct Expense: Identifiable {
    let id = UUID()
    let category: String
    let amount: Double
}

// Главное окно для ввода зарплаты и расходов
struct MainView: View {
    @AppStorage("salary") private var salary: Double = 0
    @State private var expenses: [Expense] = []
    @State private var category: String = ""
    @State private var amount: String = ""
    
    var body: some View {
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

// Окно с отчетами и круговой диаграммой
struct ReportView: View {
    @AppStorage("salary") private var salary: Double = 0
    @State private var expenses: [Expense] = [
        Expense(category: "Еда", amount: 150.0),
        Expense(category: "Транспорт", amount: 50.0),
        Expense(category: "Развлечения", amount: 75.0)
    ]
    
    var totalExpenses: Double {
        expenses.reduce(0) { $0 + $1.amount }
    }
    
    var remainingMoney: Double {
        salary - totalExpenses
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("Ваши расходы")
                .font(.largeTitle)
                .padding()

            PieChart(expenses: expenses)
                .frame(height: 300)

            Text("Всего потрачено: \(String(format: "%.2f", totalExpenses))")
                .font(.title2)
                .padding()

            Text("Остаток: \(String(format: "%.2f", remainingMoney))")
                .font(.title2)
                .padding()
        }
        .padding()
    }
}

// Круговая диаграмма для расходов
struct PieChart: View {
    let expenses: [Expense]
    
    var body: some View {
        Chart(expenses) { expense in
            SectorMark(
                angle: .value("Сумма", expense.amount),
                innerRadius: .ratio(0.5)
            )
            .foregroundStyle(by: .value("Категория", expense.category))
        }
    }
}

// Окно с настройками
struct SettingsView: View {
    @AppStorage("salary") private var salary: Double = 0

    var body: some View {
        VStack {
            Text("Настройки")
                .font(.largeTitle)
                .padding()

            Button(action: {
                salary = 0
                // Дополнительно можно сбросить расходы
            }) {
                Text("Сбросить зарплату")
                    .font(.title2)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}

// Менеджер уведомлений для планирования и отправки уведомлений
class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    func requestAuthorization() {
        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { success, error in
            if success {
                print("Разрешение получено")
            } else if let error = error {
                print("Ошибка при запросе разрешения: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleMonthlyReminder() {
        let content = UNMutableNotificationContent()
        content.title = "Не забудьте ввести зарплату!"
        content.body = "Пришло время ввести вашу зарплату за этот месяц."
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.day = 1
        dateComponents.hour = 10
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(identifier: "monthlySalaryReminder", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Ошибка при добавлении уведомления: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    ContentView()
}
