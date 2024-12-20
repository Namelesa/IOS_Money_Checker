import Foundation
import RealmSwift
import Combine

class TransactionViewModel: ObservableObject {
    
        private var realm: Realm!
        private var cancellables = Set<AnyCancellable>()
        private let transactionManager = TransactionManager()
        @Published var transactions: [TransactionModel] = []
        @Published var errorMessage: String?
        private var token: NotificationToken?
        
        init() {
            do {
                self.realm = try Realm()
                setupObserver()
                print(realm.configuration.fileURL!)
            } catch let error {
                print("Failed to initialize Realm: \(error.localizedDescription)")
            }
        }
        
        deinit {
            token?.invalidate()
        }
    
    private func setupObserver() {
                let results = realm.objects(TransactionEntity.self)
                
                token = results.observe({ [weak self] changes in
                    self?.transactions = results.map(TransactionModel.init)
                        .sorted(by: { $0.date > $1.date })
                })
        }
        

        func fetchTransactions() {
            let transactionEntities = realm.objects(TransactionEntity.self)
            self.transactions = transactionEntities.map { TransactionModel(entity: $0) }
        }
        
    func getTransactionById(id: String) -> TransactionModel? {
        do {
            let objectId = try ObjectId(string: id)
            if let transactionEntity = realm.object(ofType: TransactionEntity.self, forPrimaryKey: objectId) {
                return TransactionModel(entity: transactionEntity)
            } else {
                print("Transaction not found")
                return nil
            }
        } catch let error {
            print("Failed to get transaction: \(error.localizedDescription)")
            return nil
        }
    }
    
    // Create
    func createTransaction(date: Date, amount: Double, isIncome: Bool, categoryId: String) {
        do {
            let objectId = try ObjectId(string: categoryId)
            guard let categoryEntity = realm.object(ofType: CategoryEntity.self, forPrimaryKey: objectId) else {
                print("Category not found for ID: \(categoryId)")
                return
            }
            
            let transactionEntity = TransactionEntity()
            transactionEntity.date = date
            transactionEntity.amount = amount
            transactionEntity.isIncome = isIncome
            transactionEntity.category = categoryEntity

            try realm.write {
                realm.add(transactionEntity)
                categoryEntity.transactions.append(transactionEntity)
            }

            print("Transaction created successfully: \(transactionEntity)")
        } catch let error {
            print("Failed to create transaction: \(error.localizedDescription)")
        }
    }

   
    // Update
    func updateTransaction(id: String, newDate: Date, newAmount: Double, isIncome: Bool) {
        do {
            let objectId = try ObjectId(string: id)
            if let transactionEntity = realm.object(ofType: TransactionEntity.self, forPrimaryKey: objectId) {
                try realm.write {
                    transactionEntity.date = newDate
                    transactionEntity.amount = newAmount
                    transactionEntity.isIncome = isIncome
                }
            }
        } catch let error {
            print("Failed to update transaction: \(error.localizedDescription)")
        }
    }
    
    // Delete
    func deleteTransaction(id: String) {
        do {
            let objectId = try ObjectId(string: id)
            if let transactionEntity = realm.object(ofType: TransactionEntity.self, forPrimaryKey: objectId) {
                try realm.write {
                    realm.delete(transactionEntity)
                }
            }
        } catch let error {
            print("Failed to delete transaction: \(error.localizedDescription)")
        }
    }
    
    //MARK: - Sync
    
    func syncTransactions(userId: String) {
           // 1. Получаем не синхронизированные транзакции из Realm
           let unsyncedTransactions = self.fetchUnsyncedTransactions()
           let transactionRequests = unsyncedTransactions.map { TransactionRequest(entity: $0) }
           
           // 2. Отправляем их в Firestore
           transactionManager.uploadTransactions(userId: userId, transactions: transactionRequests)
               .flatMap { _ in
                   // 3. Получаем обновлённые транзакции из Firestore за последний год
                   self.transactionManager.fetchTransactions(userId: userId, since: Calendar.current.date(byAdding: .year, value: -1, to: Date())!)
               }
               .sink(receiveCompletion: { completion in
                   if case let .failure(error) = completion {
                       self.errorMessage = "Error during sync: \(error.localizedDescription)"
                   }
               }, receiveValue: { updatedTransactions in
                   // 4. Обновляем Realm с полученными данными
                   self.updateTransactions(with: updatedTransactions)
               })
               .store(in: &cancellables)
       }
        
    
    
    private func fetchUnsyncedTransactions() -> [TransactionEntity] {
        return Array(realm.objects(TransactionEntity.self).filter("isSync == false"))
    }
    
    private func updateTransactions(with transactions: [TransactionRequest]) {
            try? realm.write {
                transactions.forEach { request in
                    let transactionEntity = TransactionEntity()
                    transactionEntity.id = try! ObjectId(string: request.id)
                    transactionEntity.date = request.date
                    transactionEntity.amount = Double(truncating: request.amount as NSNumber)
                    transactionEntity.isIncome = request.isIncome
                    transactionEntity.isSync = true
                    realm.add(transactionEntity, update: .modified)
                }
            }
        }
}
