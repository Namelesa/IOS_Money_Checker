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
        return checkIfUserExists(withEmail: email)
            .flatMap { userExists -> AnyPublisher<Void, Error> in
                guard !userExists else {
                    return Fail(error: NSError(domain: "FirestoreError", code: 1, userInfo: [NSLocalizedDescriptionKey: "User with this email already exists."]))
                        .eraseToAnyPublisher()
                }
                
                let user = User(id: userId, name: fullName, email: email, lastSyncDate: Date())
                let defaultCategories = self.defaultCategories()
                
                // Добавление пользователя в Firestore
                return self.addUserToFirestore(user)
                    .flatMap { _ in
                        // Сначала добавляем пользователя в локальную базу
                        Future<Void, Error> { promise in
                            self.addOrUpdateUserToRealm(user: UserEntity(model: user))
                            promise(.success(()))
                        }
                    }
                    .flatMap { _ in
                        // Затем добавляем категории
                        self.addCategoriesToFirestoreAndRealm(defaultCategories, user: user)
                    }
                    .eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
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
    
    func addOrUpdateUserToRealm(user: UserEntity) {
        let realm = try! Realm()
        try! realm.write {
            realm.add(user, update: .modified)
        }
        print("User with ID \(user.id) was successfully added or updated in Realm.")
    }

    private func addCategoryToRealm(_ category: CategoryFirestore, userId: String) {
        guard let realm = realm else { return }
        do {
            let user = realm.object(ofType: UserEntity.self, forPrimaryKey: userId)!
            let categoryEntity = CategoryEntity(id: category.id, name: category.name, userEntity: user)
            try realm.write {
                realm.add(categoryEntity)
                user.categories.append(categoryEntity)
            }
            print("Category \(category.name) added to Realm.")
        } catch {
            errorMessage = "Failed to save category to Realm: \(error)"
            print("Error saving category to Realm: \(error)")
        }
    }
    
    private func checkIfUserExists(withEmail email: String) -> AnyPublisher<Bool, Error> {
        let usersQuery = db.collection("users").whereField("email", isEqualTo: email)
        
        return Future<Bool, Error> { promise in
            usersQuery.getDocuments { snapshot, error in
                if let error = error {
                    promise(.failure(error))
                    return
                }
                // Якщо користувач існує, повертаємо true
                promise(.success(snapshot?.isEmpty == false))
            }
        }
        .eraseToAnyPublisher()
    }

    private func addUserToFirestore(_ user: User) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            do {
                try self.db.collection("users").document(user.id).setData(from: user) { error in
                    if let error = error {
                        promise(.failure(error))
                    } else {
                        print("User successfully added to Firestore with ID: \(user.id)")
                        promise(.success(()))
                    }
                }
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }

    private func addCategoriesToFirestoreAndRealm(_ categories: [CategoryFirestore], user: User) -> AnyPublisher<Void, Error> {
        let userEntity = UserEntity(model: user)
        
        let categoryPromises = categories.map { category in
            Future<Void, Error> { promise in
                do {
                    // Добавляем категорию в Firestore
                    try self.db.collection("users")
                        .document(user.id)
                        .collection("categories")
                        .document(category.id)
                        .setData(from: category) { error in
                            if let error = error {
                                promise(.failure(error))
                            } else {
                                // Добавляем категорию в Realm
                                self.addCategoryToRealm(category, userId: user.id)
                                promise(.success(()))
                            }
                        }
                } catch {
                    promise(.failure(error))
                }
            }
        }
        
        return Publishers.MergeMany(categoryPromises)
            .collect()
            .flatMap { _ in
                Future<Void, Error> { promise in
                    promise(.success(()))
                }
            }
            .eraseToAnyPublisher()
    }

    private func defaultCategories() -> [CategoryFirestore] {
        // Категорії за замовчуванням
        return [
            // Витрати
            CategoryFirestore(id: UUID().uuidString, name: "Groceries"),
            CategoryFirestore(id: UUID().uuidString, name: "Transport"),
            CategoryFirestore(id: UUID().uuidString, name: "Utilities"),
            CategoryFirestore(id: UUID().uuidString, name: "Entertainment"),
            CategoryFirestore(id: UUID().uuidString, name: "Healthcare"),
            CategoryFirestore(id: UUID().uuidString, name: "Clothing"),
            CategoryFirestore(id: UUID().uuidString, name: "Dining Out"),
            // Доходи
            CategoryFirestore(id: UUID().uuidString, name: "Salary"),
            CategoryFirestore(id: UUID().uuidString, name: "Investments"),
            CategoryFirestore(id: UUID().uuidString, name: "Freelance")
        ]
    }
    
    private func addCategoriesToFirestore(_ categories: [CategoryFirestore], userId: String) -> AnyPublisher<Void, Error> {
        let categoryPromises = categories.map { category in
            Future<Void, Error> { categoryPromise in
                do {
                    try self.db.collection("users")
                        .document(userId)
                        .collection("categories")
                        .document(category.id)
                        .setData(from: category) { error in
                            if let error = error {
                                categoryPromise(.failure(error))
                            } else {
                                categoryPromise(.success(()))
                            }
                        }
                } catch {
                    categoryPromise(.failure(error))
                }
            }
        }
        
        // Объединяем все категории и ждём их обработки
        return Publishers.MergeMany(categoryPromises)
            .collect()
            .flatMap { _ in
                Future<Void, Error> { promise in
                    promise(.success(()))
                }
            }
            .eraseToAnyPublisher()
    }

}

