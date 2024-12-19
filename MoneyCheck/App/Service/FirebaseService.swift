//
//  FirebaseService.swift
//  MoneyCheck
//
//  Created by Dima Zanuda on 17.12.2024.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine

public class FirebaseService {
    
    public func registerUser(email: String, password: String) -> Future<String, Error> {
        Future { promise in
            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success((result?.user.uid)!))
                }
            }
        }
    }

    public func getIDToken() -> Future<String, Error> {
        Future { promise in
            guard let currentUser = Auth.auth().currentUser else {
                promise(.failure(NSError(domain: "Auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user logged in"])))
                return
            }
            currentUser.getIDTokenForcingRefresh(true) { idToken, error in
                if let error = error {
                    promise(.failure(error))
                } else if let idToken = idToken {
                    promise(.success(idToken))
                } else {
                    promise(.failure(NSError(domain: "Auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get ID token"])))
                }
            }
        }
    }
}
