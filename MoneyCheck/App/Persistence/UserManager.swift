//
//  UserManager.swift
//  MoneyCheck
//
//  Created by Dima Zanuda on 17.12.2024.
//


import Foundation
import RealmSwift
import FirebaseFirestore
import Combine

final class UserManager: ObservableObject {
    
    @Published var errorMessage: String = ""
    @Published var isLoggedIn: Bool = false
    
    private let db = Firestore.firestore()
    private let realm : Realm?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        do {
            realm = try Realm()
        } catch {
            errorMessage = "Couldn't initialize Realm database: \(error)"
            realm = nil
        }
    }
    
    // MARK: - Create New User
    func createNewUser(userId: String, email: String, fullName: String) -> AnyPublisher<Void, Error> {
        let user = User(id: userId, name: fullName, email: email, lastSyncDate: Date.now)
        
        return Future<Void, Error> { promise in
            do {
                try self.db.collection("users").document(userId).setData(from: user) { error in
                    if let error = error {
                        promise(.failure(error))
                    } else {
                        self.addUserToRealm(user)
                        print("User successfully added with ID: \(userId)")
                        promise(.success(()))
                    }
                }
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Fetch User
    func fetchUser(userId: String) -> AnyPublisher<User?, Error> {
        Future<User?, Error> { promise in
            self.db.collection("users").document(userId).getDocument(as: User.self) { result in
                switch result {
                case .success(let user):
                    promise(.success(user))
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Update User
    func updateUser(userId: String, email: String? = nil, fullName: String? = nil) -> AnyPublisher<Void, Error> {
        var updates: [String: Any] = [:]
        if let email = email { updates["email"] = email }
        if let fullName = fullName { updates["name"] = fullName }
        
        return Future<Void, Error> { promise in
            self.db.collection("users").document(userId).updateData(updates) { error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    print("User updated successfully")
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Delete User
    func deleteUser(userId: String) -> AnyPublisher<Void, Error> {
        Future<Void, Error> { promise in
            self.db.collection("users").document(userId).delete { error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    print("User deleted successfully")
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Set Email Verified
    func setEmailVerified(userId: String) -> AnyPublisher<Void, Error> {
        updateUser(userId: userId, email: nil, fullName: nil)
            .flatMap { _ in
                self.updateUser(userId: userId, fullName: nil)
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Update Sync Dates
    func updateSyncDates(userId: String) -> AnyPublisher<Void, Error> {
        let now = Date()
        let nextSyncDate = Calendar.current.date(byAdding: .day, value: 1, to: now) ?? now
        
        let updates: [String: Any] = [
            "lastSyncDate": now,
            "nextSyncDate": nextSyncDate
        ]
        
        return Future<Void, Error> { promise in
            self.db.collection("users").document(userId).updateData(updates) { error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    print("Sync dates updated successfully")
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Helpers
    func handlePublisherError<T>(_ publisher: AnyPublisher<T, Error>) {
        publisher
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case let .failure(error) = completion {
                    self.errorMessage = error.localizedDescription
                    print("Error: \(error.localizedDescription)")
                }
            } receiveValue: { _ in
                print("Operation completed successfully")
            }
            .store(in: &cancellables)
    }
}


extension UserManager{
    
    private func addUserToRealm(_ user: User) {
        let userEntity = UserEntity(model: user)
        do {
            try realm?.write {
                realm?.add(userEntity)
            }
            print("User successfully added to Realm with ID: \(user.id)")
        } catch {
            errorMessage = "Failed to save user to Realm: \(error)"
            print("Error saving user to Realm: \(error)")
        }
    }
}

