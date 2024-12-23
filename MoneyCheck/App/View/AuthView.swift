//
//  AuthView.swift
//  MoneyCheck
//
//  Created by Максим Билык on 17.12.2024.
//

import SwiftUI

struct AuthView: View {
    @EnvironmentObject var auth: AuthenticationViewModel
    @State var isLoggedIn: Bool = false
    @State private var email: String = ""
    @State private var name: String = ""
    @State private var password: String = ""
    @State private var showError: Bool = false
    
    @State private var showAuthLoader: Bool = false
    @State private var showInvalidPWAlert: Bool = false
    @FocusState private var emailIsFocused: Bool
    @FocusState private var passwordIsFocused: Bool
        

    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 10)
            
            Text("Login or Sing Up")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            VStack(spacing: 15) {
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .submitLabel(.next)
                    .focused($emailIsFocused)
                
                TextField("FullName", text: $name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .submitLabel(.next)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .focused($passwordIsFocused)
                    .submitLabel(.next)
            }
            .padding(.horizontal)
            
            LoginButton(
                emailAddress: $email,
                password: $password,
                fullName: $name,
                showAuthLoader: $showAuthLoader,
                showInvalidPWAlert: $showInvalidPWAlert,
                isAuthenticated: $isLoggedIn,
                buttonText: "Sign In")
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            
            LoginButton(
                emailAddress: $email,
                password: $password,
                fullName: $name,
                showAuthLoader: $showAuthLoader,
                showInvalidPWAlert: $showInvalidPWAlert,
                isAuthenticated: $isLoggedIn,
                buttonText: "Sign up")
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            
            HStack {
                Image("GoogleIcon")
                    .resizable()
                    .frame(width: 10, height: 10)
                
                Text("Sign in with Google")
                    .font(.system(size: 16, weight: .medium, design: .default))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 20)
            ) .frame(width: 210, height: 40)
                .padding(.bottom, 20)
                .onTapGesture {
                    Task {
                        await auth.signInWithGoogle()
                        if auth.state == .signedIn {
                            isLoggedIn = true
                        }
                    }
                }
                                
        }
        .padding(.horizontal)
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
    }
}
