//
//  LoginButton.swift
//  MoneyCheck
//
//  Created by Dima Zanuda on 18.12.2024.
//

import SwiftUI
import FirebaseAuth

struct LoginButton : View {
    @Binding var emailAddress: String
    @Binding var password: String
    @Binding var fullName: String
    @Binding var showAuthLoader: Bool
    @Binding var showInvalidPWAlert: Bool
    @Binding var isAuthenticated: Bool
    var buttonText: String
    @EnvironmentObject var authViewModel: AuthenticationViewModel
        
    var body: some View {
        Button(action: {
            showAuthLoader = true
            Task {
                if buttonText == "Sign In" {
                    await authViewModel.signInWithEmail(email: emailAddress, password:password)
                } else {
                    authViewModel.signUp(email: emailAddress, password: password, fullName: fullName)
                }
                
                if authViewModel.state != .signedIn {
                    showInvalidPWAlert = true
                } else {
                    isAuthenticated = true
                }
                showAuthLoader = false
            }
        }) {
            Text(buttonText)
                .disabled(emailAddress.isEmpty || password.isEmpty)
                .alert(isPresented: $showInvalidPWAlert) {
                Alert(title: Text("Email or Password Incorrect"))
            }
        }
    }
}


struct LoginButton_Previews: PreviewProvider {
    static var previews: some View {
        LoginButton(emailAddress: .constant(""), password: .constant(""), fullName: .constant(""), showAuthLoader: .constant(false), showInvalidPWAlert: .constant(false), isAuthenticated: .constant(false), buttonText: "Sign In")
    }
}
