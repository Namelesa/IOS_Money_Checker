//
//  CategoryViewModel.swift
//  MoneyCheck
//
//  Created by Dima Zanuda on 08.12.2024.
//

import Foundation
import RealmSwift

class CategoryViewModel: ObservableObject {
    private var realm: Realm!
    @Published var categories: [Category] = []
    
    private var token: NotificationToken?

    init() {
        do {
            self.realm = try Realm()
            setupObserver()
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
            let results = realm.objects(CategoryEntity.self)
            
            token = results.observe({ [weak self] changes in
                // 6
                self?.categories = results.map(Category.init)
                    .sorted(by: { $0.name < $1.name})
            })
        } catch let error {
            print(error.localizedDescription)
        }
    }

    // MARK: - CRUD Operations

    // Create
    func createCategory(name: String) {
        let categoryEntity = CategoryEntity()
        categoryEntity.name = name

        try! realm.write {
            realm.add(categoryEntity)
        }
        fetchCategories()
    }

    // Read
    func fetchCategories() {
        let categoryEntities = realm.objects(CategoryEntity.self)
        self.categories = categoryEntities.map { Category(entity: $0) }
    }
    
    func getCategoryById(id: String) -> Category? {
        do {
            let objectId = try ObjectId(string: id)
            if let categoryEntity = realm.object(ofType: CategoryEntity.self, forPrimaryKey: objectId) {
                return Category(entity: categoryEntity)
            }
            else {
                print("Category not found")
                return nil
            }
        } catch let error{
            print("Failed to get category: \(error.localizedDescription)")
            return nil
        }
    }

    // Update
    func updateCategory(id: String, newName: String) {
        do {
            let objectId = try ObjectId(string: id)
            if let categoryEntity = realm.object(ofType: CategoryEntity.self, forPrimaryKey: objectId) {
                try realm.write {
                    categoryEntity.name = newName
                }
                fetchCategories()
            }
        } catch {
            print("Failed to update category: \(error.localizedDescription)")
        }
    }

    func deleteCategory(id: String) {
        do {
            let objectId = try ObjectId(string: id)
            if let categoryEntity = realm.object(ofType: CategoryEntity.self, forPrimaryKey: objectId) {
                try realm.write {
                    realm.delete(categoryEntity)
                }
                fetchCategories()
            }
        } catch {
            print("Failed to delete category: \(error.localizedDescription)")
        }
    }
}
