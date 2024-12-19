//
//  DependencyContainer.swift
//  MoneyCheck
//
//  Created by Dima Zanuda on 19.12.2024.
//

import Foundation

class DependencyContainer {
    static let shared = DependencyContainer()
    private(set) lazy var transactionManager = TransactionViewModel()
    private(set) lazy var categoryManager = CategoryViewModel()
    private(set) lazy var firebaseService = FirebaseService()
    private(set) lazy var userManager = UserManager()
    private(set) lazy var authManager: AuthenticationViewModel = {
        AuthenticationViewModel(firebaseService: firebaseService, userManager: userManager)
    }()
    
    private init() { }
}
