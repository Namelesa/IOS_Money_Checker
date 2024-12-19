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
    @Published var errorMessage: String = ""
    @Published var signInMethod: String = "NaN"
    @Published var restoreGoogleSignIn: Bool = false
    
    @MainActor
    func signInWithEmail(email: String, password: String) async {
            do {
                try await Auth.auth().signIn(withEmail: email, password: password)
                self.state = .signedIn
                UserDefaults.standard.set(true, forKey: "isLoggedIn")
                self.signInMethod = "Email / Password"
            }
            catch {
                print(error.localizedDescription)
                self.errorMessage = error.localizedDescription
            }
        }
    
    func signUp(email: String, password: String, fullName: String) {
        self.firebaseService.registerUser(email: email, password: password)
            .flatMap {userId -> AnyPublisher<Void, Error> in
                self.userManager.createNewUser(userId: userId, email: email, fullName: fullName)}
                .receive(on: DispatchQueue.main)
                .sink { [weak self] completion in
                    switch completion {
                    case .failure(let error):
                        self?.errorMessage = "Sign-up failed: \(error.localizedDescription)"
                    case .finished:
                        self?.state = .signedIn
                        UserDefaults.standard.set(true, forKey: "isLoggedIn")
                        self?.signInMethod = "Email / Password"
                        print("Sign-up and registration completed.")
                    }
                } receiveValue: { _ in }
                .store(in: &cancellables)
        }

    
    func signOut() {
        GIDSignIn.sharedInstance.signOut()
            do {
                try Auth.auth().signOut()
                self.state = .signedOut
                UserDefaults.standard.set(false, forKey: "isLoggedIn")
            } catch {
                print(error.localizedDescription)
            }
        }
    
    
    func signInWithGoogle() async {
        if GIDSignIn.sharedInstance.hasPreviousSignIn() {
            do {
                let result = try await GIDSignIn.sharedInstance.restorePreviousSignIn()
                print("Restoring previous session")
                await authenticateGoogleUser(for: result)
            } catch {
                print("Error restoring previous Google sign-in session: \(error.localizedDescription)")
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                }
            }
        } else {
            guard let rootViewController = await getRootViewController() else {
                print("Unable to retrieve rootViewController")
                await MainActor.run {
                    self.errorMessage = "Unable to retrieve rootViewController"
                }
                return
            }
            
            do {
                let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
                await authenticateGoogleUser(for: result.user)
            } catch {
                print("Error during Google sign-in: \(error.localizedDescription)")
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    @MainActor
    func authenticateGoogleUser(for user: GIDGoogleUser?) async {

            guard let idToken = user?.idToken?.tokenString else { return }
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user?.accessToken.tokenString ?? "")
            
            do {
                let user = try await Auth.auth().signIn(with: credential)
                self.state = .signedIn
                UserDefaults.standard.set(true, forKey: "isLoggedIn")
                self.signInMethod = "Google"
                self.userManager.createNewUser(userId: user.user.uid, email: user.user.email ?? "", fullName: user.user.displayName ?? "")
                    .sink { completion in
                        switch completion {
                        case .failure(let error):
                            self.errorMessage = "Failed to create user: \(error.localizedDescription)"
                        case .finished:
                            print("User created successfully")
                        }
                    } receiveValue: { _ in }
                    .store(in: &cancellables)
            }
            catch {
                print(error.localizedDescription)
                self.errorMessage = error.localizedDescription
            }
        }
    
    
    
    private func getRootViewController() async -> UIViewController? {
        await MainActor.run {
            guard let windowScene = UIApplication.shared.connectedScenes.first(where: { $0 is UIWindowScene }) as? UIWindowScene,
                  let rootVC = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController else {
                return nil
            }
            return rootVC
        }
    }
}


