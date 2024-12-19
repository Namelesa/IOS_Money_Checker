//
//  TransactionManager.swift
//  MoneyCheck
//
//  Created by Dima Zanuda on 17.12.2024.
//

import Foundation
import FirebaseFirestore
import Combine

final class TransactionManager: ObservableObject {
    
    // MARK: - Properties
    private let db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Add Transaction
    func addTransaction(userId: String, transaction: TransactionRequest) -> AnyPublisher<Void, Error> {
        let transactionRef = db.collection("users").document(userId).collection("transactions").document(transaction.id)
        
        return Future<Void, Error> { promise in
            do {
                let data = try JSONEncoder().encode(transaction)
                let dictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                
                transactionRef.setData(dictionary ?? [:]) { error in
                    if let error = error {
                        promise(.failure(error))
                    } else {
                        promise(.success(()))
                    }
                }
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func uploadTransactions(userId: String, transactions: [TransactionRequest]) -> AnyPublisher<Void, Error> {
            let userRef = db.collection("users").document(userId).collection("transactions")
            
            return Future<Void, Error> { promise in
                let batch = self.db.batch()
                transactions.forEach { transaction in
                    let docRef = userRef.document(transaction.id)
                    do {
                        let data = try JSONEncoder().encode(transaction)
                        let dictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                        batch.setData(dictionary ?? [:], forDocument: docRef)
                    } catch {
                        promise(.failure(error))
                    }
                }
                batch.commit { error in
                    if let error = error {
                        promise(.failure(error))
                    } else {
                        promise(.success(()))
                    }
                }
            }
            .eraseToAnyPublisher()
        }
    
    // MARK: - Remove Transaction
    func removeTransaction(userId: String, transactionId: String) -> AnyPublisher<Void, Error> {
        let transactionRef = db.collection("users").document(userId).collection("transactions").document(transactionId)
        
        return Future<Void, Error> { promise in
            transactionRef.delete { error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Sync Transactions
    
    func fetchTransactions(userId: String, since date: Date) -> AnyPublisher<[TransactionRequest], Error> {
            let userRef = db.collection("users").document(userId).collection("transactions")
            
            return Future<[TransactionRequest], Error> { promise in
                userRef.whereField("date", isGreaterThan: date)
                    .getDocuments { snapshot, error in
                        if let error = error {
                            promise(.failure(error))
                        } else {
                            let transactions = snapshot?.documents.compactMap { doc -> TransactionRequest? in
                                try? doc.data(as: TransactionRequest.self)
                            } ?? []
                            promise(.success(transactions))
                        }
                    }
            }
            .eraseToAnyPublisher()
        }
}



struct SyncRequest: Encodable {
    let identityId: String
    let transactions: [TransactionRequest]?
    let syncInterval: Int
}

struct TransactionRequest: Codable {
    let id: String
    let amount: Decimal
    let date: Date
    let isIncome: Bool
    let categoryId: String
    let categoryName: String
    
    init(entity: TransactionEntity) {
        self.id = entity.id.stringValue
        self.amount = Decimal(entity.amount)
        self.date = entity.date
        self.isIncome = entity.isIncome
        self.categoryId = entity.category.id.stringValue
        self.categoryName = entity.category.name
    }
        
}
