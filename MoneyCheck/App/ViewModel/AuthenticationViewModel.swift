//
//  AuthenticationViewModel.swift
//  MoneyCheck
//
//  Created by Dima Zanuda on 17.12.2024.
//

import FirebaseAuth
import Combine
import GoogleSignIn

public class AuthenticationViewModel : NSObject, ObservableObject {
    enum SignInState {
           case signedIn
           case signedOut
       }
    
    init(firebaseService: FirebaseService, userManager: UserManager) {
            self.firebaseService = firebaseService
            self.userManager = userManager
            super.init()
            if GIDSignIn.sharedInstance.hasPreviousSignIn() {
                restoreGoogleSignIn = true
            }
        }
    
    private var cancellables = Set<AnyCancellable>()
    private var firebaseService: FirebaseService
    private var userManager : UserManager
    @Published var state: SignInState = .signedOut
    @Published var userId: String = ""
    @Published var errorMessage: String = ""
    @Published var signInMethod: String = "NaN"
    @Published var restoreGoogleSignIn: Bool = false
    
    @MainActor
    func signInWithEmail(email: String, password: String) async {
            do {
                let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
                self.state = .signedIn
                self.userId = authResult.user.uid
                UserDefaults.standard.set(true, forKey: "isLoggedIn")
                self.signInMethod = "Email / Password"
            }
            catch {
                self.handleError(error)
            }
        }
    @MainActor
    func signUp(email: String, password: String, fullName: String) {
        self.firebaseService.registerUser(email: email, password: password)
            .flatMap { [weak self] userId -> AnyPublisher<Void, Error> in
                       guard let self = self else {
                           return Fail(error: NSError(domain: "Self is nil", code: 0, userInfo: nil))
                               .eraseToAnyPublisher()
                       }
                       self.userId = userId // Сохраняем userId
                       return self.userManager.createNewUser(userId: userId, email: email, fullName: fullName)
                   }
                .receive(on: DispatchQueue.main)
                .sink { [weak self] completion in
                    switch completion {
                    case .failure(let error):
                        self?.handleError(error)
                    case .finished:
                        self?.state = .signedIn
                        UserDefaults.standard.set(true, forKey: "isLoggedIn")
                        self?.signInMethod = "Email / Password"
                        print("Sign-up and registration completed.")
                    }
                } receiveValue: { _ in }
                .store(in: &cancellables)
        }

    @MainActor
    func signOut() {
        GIDSignIn.sharedInstance.signOut()
            do {
                try Auth.auth().signOut()
                self.userId = ""
                self.state = .signedOut
                UserDefaults.standard.set(false, forKey: "isLoggedIn")
            } catch {
                print(error.localizedDescription)
            }
        }
    
    @MainActor
        func signInWithGoogle() async {
            if GIDSignIn.sharedInstance.hasPreviousSignIn() {
                // Восстанавливаем предыдущую сессию
                do {
                    let result = try await GIDSignIn.sharedInstance.restorePreviousSignIn()
                    print("Restoring previous session")
                    let user = await authenticateGoogleUser(for: result)
                    self.userId = user?.uid ?? ""
                } catch {
                    print("Error restoring previous Google sign-in session: \(error.localizedDescription)")
                    errorMessage = "Failed to restore previous session: \(error.localizedDescription)"
                }
            } else {
                // Выполняем новую аутентификацию
                guard let rootViewController = await getRootViewController() else {
                    print("Unable to retrieve rootViewController")
                    errorMessage = "Unable to retrieve rootViewController"
                    return
                }
                
                do {
                    let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
                    if let user = await authenticateGoogleUser(for: result.user) {
                        // Создание нового пользователя
                        userManager.createNewUser(userId: user.uid, email: user.email ?? "", fullName: user.displayName ?? "")
                            .sink { [weak self] completion in
                                switch completion {
                                case .failure(let error):
                                    self?.handleError(error)
                                case .finished:
                                    self?.userId = user.uid
                                    print("User created successfully")
                                }
                            } receiveValue: { _ in }
                            .store(in: &cancellables)
                    }
                } catch {
                    print("Error during Google sign-in: \(error.localizedDescription)")
                    errorMessage = "Failed to sign in with Google: \(error.localizedDescription)"
                }
            }
        }
        
        @MainActor
        private func authenticateGoogleUser(for user: GIDGoogleUser?) async -> FirebaseAuth.User? {
            guard let user = user,
                  let idToken = user.idToken?.tokenString else {
                errorMessage = "Invalid user or token"
                return nil
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            
            do {
                let authResult = try await Auth.auth().signIn(with: credential)
                print("Google sign-in successful")
                state = .signedIn
                UserDefaults.standard.set(true, forKey: "isLoggedIn")
                signInMethod = "Google"
                return authResult.user
            } catch {
                print("Firebase authentication failed: \(error.localizedDescription)")
                errorMessage = "Authentication failed: \(error.localizedDescription)"
                return nil
            }
        }
    
    
    @MainActor
    private func getRootViewController() async -> UIViewController? {
        await MainActor.run {
            guard let windowScene = UIApplication.shared.connectedScenes.first(where: { $0 is UIWindowScene }) as? UIWindowScene,
                  let rootVC = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController else {
                return nil
            }
            return rootVC
        }
    }
    
    private func handleError(_ error: Error) {
        DispatchQueue.main.async {
            self.state = .signedOut
            self.errorMessage = error.localizedDescription
        }
    }
}


