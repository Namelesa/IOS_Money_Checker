import Foundation
import RealmSwift

class TransactionViewModel: ObservableObject {
    private var realm: Realm!
        @Published var transactions: [TransactionModel] = []
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
            do {
                self.realm = try Realm()
                let results = realm.objects(TransectionEntity.self)
                
                token = results.observe({ [weak self] changes in
                    self?.transactions = results.map(TransactionModel.init)
                        .sorted(by: { $0.date > $1.date })
                })
            } catch let error {
                print(error.localizedDescription)
            }
        }
        

        func fetchTransactions() {
            let transactionEntities = realm.objects(TransectionEntity.self)
            self.transactions = transactionEntities.map { TransactionModel(entity: $0) }
        }
        
    func getTransactionById(id: String) -> TransactionModel? {
        do {
            let objectId = try ObjectId(string: id)
            if let transactionEntity = realm.object(ofType: TransectionEntity.self, forPrimaryKey: objectId) {
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
            
            let transactionEntity = TransectionEntity()
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
            if let transactionEntity = realm.object(ofType: TransectionEntity.self, forPrimaryKey: objectId) {
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
            if let transactionEntity = realm.object(ofType: TransectionEntity.self, forPrimaryKey: objectId) {
                try realm.write {
                    realm.delete(transactionEntity)
                }
            }
        } catch let error {
            print("Failed to delete transaction: \(error.localizedDescription)")
        }
    }
}
