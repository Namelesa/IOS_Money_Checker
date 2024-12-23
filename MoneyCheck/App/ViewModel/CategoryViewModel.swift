import Foundation
import RealmSwift

class CategoryViewModel: ObservableObject {
    private var realm: Realm!
    @Published var categories: [Category] = []
    @Published var userId: String = ""

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
        guard !userId.isEmpty else {
            print("User ID is empty. Observer not set up.")
            return
        }

        guard let userEntity = realm.object(ofType: UserEntity.self, forPrimaryKey: userId) else {
            print("User not found with ID: \(userId)")
            return
        }

        let results = realm.objects(CategoryEntity.self).filter("user == %@", userEntity)

        token = results.observe({ [weak self] changes in
            guard let self = self else { return }
            switch changes {
            case .initial:
                self.categories = results.map(Category.init).sorted(by: { $0.name < $1.name })
            case .update(_, let deletions, let insertions, let modifications):
                print("Deletions: \(deletions), Insertions: \(insertions), Modifications: \(modifications)")
                self.categories = results.map(Category.init).sorted(by: { $0.name < $1.name })
            case .error(let error):
                print("Error observing categories: \(error)")
            }
        })
    }

    // MARK: - CRUD Operations

    // Create
    func createCategory(name: String) {
        guard !userId.isEmpty, let userEntity = realm.object(ofType: UserEntity.self, forPrimaryKey: userId) else {
            print("User ID is empty or user not found")
            return
        }

        let categoryEntity = CategoryEntity()
        categoryEntity.name = name
        categoryEntity.user = userEntity

        do {
            try realm.write {
                realm.add(categoryEntity)
            }
            print("Category created: \(name)")
        } catch let error {
            print("Failed to create category: \(error.localizedDescription)")
        }
    }

    // Read
    func fetchCategories() {
        guard !userId.isEmpty else {
            print("User ID is empty")
            return
        }

        guard let userEntity = realm.object(ofType: UserEntity.self, forPrimaryKey: userId) else {
            print("User not found with ID: \(userId)")
            return
        }

        let categoryEntities = realm.objects(CategoryEntity.self).filter("user == %@", userEntity)

        self.categories = categoryEntities.map { Category(entity: $0) }.sorted(by: { $0.name < $1.name })
    }

    func getCategoryById(id: String) -> Category? {
        if let categoryEntity = realm.object(ofType: CategoryEntity.self, forPrimaryKey: id) {
            return Category(entity: categoryEntity)
        } else {
            print("Category not found")
            return nil
        }
    }

    // Update
    func updateCategory(id: String, newName: String) {
        do {
            if let categoryEntity = realm.object(ofType: CategoryEntity.self, forPrimaryKey: id) {
                try realm.write {
                    categoryEntity.name = newName
                }
            }
        } catch {
            print("Failed to update category: \(error.localizedDescription)")
        }
    }

    func deleteCategory(id: String) {
        do {
            if let categoryEntity = realm.object(ofType: CategoryEntity.self, forPrimaryKey: id) {
                try realm.write {
                    realm.delete(categoryEntity)
                }
            }
        } catch {
            print("Failed to delete category: \(error.localizedDescription)")
        }
    }
}

