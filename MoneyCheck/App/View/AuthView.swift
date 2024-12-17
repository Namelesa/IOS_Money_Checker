//
//  AuthView.swift
//  MoneyCheck
//
//  Created by Максим Билык on 17.12.2024.
//

import SwiftUI

struct AuthView: View {
    @Binding var isLoggedIn: Bool
    @State private var email: String = ""
    @State private var name: String = ""
    @State private var password: String = ""
    @State private var showError: Bool = false

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
                
                TextField("FullName", text: $name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)

                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding(.horizontal)

            Button(action: handleAuth) {
                Text("Login / Sing Up")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)

            if showError {
                Text("Innput correct data")
                    .foregroundColor(.red)
                    .font(.caption)
            }
        }
        .padding()
    }

    private func handleAuth() {
        guard !email.isEmpty, !password.isEmpty else {
            showError = true
            return
        }
        
        isLoggedIn = true
    }
}
