import Foundation
import RealmSwift
import Combine

class TransactionViewModel: ObservableObject {
    
        private var realm: Realm!
        private var cancellables = Set<AnyCancellable>()
        private let transactionManager = TransactionManager()
        @Published var transactions: [TransactionModel] = []
        @Published var errorMessage: String?
        @Published var userId: String = ""
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
        guard !userId.isEmpty else {
            print("User ID is empty. Observer not set up.")
            return
        }

        guard let userObjectId = try? ObjectId(string: userId),
              let userEntity = realm.object(ofType: UserEntity.self, forPrimaryKey: userObjectId) else {
            print("User not found with ID: \(userId)")
            return
        }

        let results = realm.objects(TransactionEntity.self).filter("user == %@", userEntity)

        token = results.observe({ [weak self] changes in
            guard let self = self else { return }
            switch changes {
            case .initial:
                self.transactions = results.map(TransactionModel.init).sorted(by: { $0.date > $1.date })
            case .update(_, let deletions, let insertions, let modifications):
                print("Deletions: \(deletions), Insertions: \(insertions), Modifications: \(modifications)")
                self.transactions = results.map(TransactionModel.init).sorted(by: { $0.date > $1.date })
            case .error(let error):
                print("Error observing transactions: \(error)")
            }
        })
    }


    func fetchTransactions() {
        
        guard !userId.isEmpty else {
            print("User ID is empty")
            return
        }

        guard let userEntity = realm.object(ofType: UserEntity.self, forPrimaryKey: userId) else {
            print("User not found with ID: \(userId)")
            return
        }
        
        let transactionEntities = realm.objects(TransactionEntity.self).filter("user == %@", userEntity)

        self.transactions = transactionEntities.map { TransactionModel(entity: $0) }.sorted(by: { $0.date < $1.date })
    }
        
    func getTransactionById(id: String) -> TransactionModel? {
        do {
            if let transactionEntity = realm.object(ofType: TransactionEntity.self, forPrimaryKey: id) {
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
    func createTransaction(date: Date, amount: Double, isIncome: Bool, categoryId: String, userId: String) {
        do {
            guard let categoryEntity = realm.object(ofType: CategoryEntity.self, forPrimaryKey: categoryId) else {
                print("Category not found for ID: \(categoryId)")
                return
            }
            guard let userEnitity = realm.object(ofType: UserEntity.self, forPrimaryKey: userId) else {
                print("Category not found for ID: \(userId)")
                return
            }
            
            
            let transactionEntity = TransactionEntity()
            transactionEntity.id = UUID().uuidString
            transactionEntity.date = date
            transactionEntity.amount = amount
            transactionEntity.isIncome = isIncome
            transactionEntity.category = categoryEntity
            transactionEntity.user = userEnitity

            try realm.write {
                realm.add(transactionEntity)
                categoryEntity.transactions.append(transactionEntity)
                userEnitity.transactions.append(transactionEntity)
            }

            print("Transaction created successfully: \(transactionEntity)")
        } catch let error {
            print("Failed to create transaction: \(error.localizedDescription)")
        }
    }
    
    // Delete
    func deleteTransaction(id: String) {
        do {
            if let transactionEntity = realm.object(ofType: TransactionEntity.self, forPrimaryKey: id) {
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
                    transactionEntity.id = request.id
                    transactionEntity.date = request.date
                    transactionEntity.amount = Double(truncating: request.amount as NSNumber)
                    transactionEntity.isIncome = request.isIncome
                    transactionEntity.isSync = true
                    realm.add(transactionEntity, update: .modified)
                }
            }
        }
}


    
    
