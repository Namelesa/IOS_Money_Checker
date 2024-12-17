//
//  Profile.swift
//  MoneyCheck
//
//  Created by Максим Билык on 09.12.2024.
//

import SwiftUI

struct Profile: View {
    @State private var isSyncing = false
    @State private var syncResult: String? = nil
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false

    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .frame(width: 120, height: 120)
                    .foregroundColor(.blue)
                    .padding(.top, 50)

                VStack(spacing: 10) {
                    Button(action: syncData) {
                        HStack {
                            Image(systemName: "arrow.clockwise.circle")
                                .font(.title2)
                                .foregroundColor(.blue)
                            Text("Sync Data")
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                    
                    logoutButton
                    
                    if let result = syncResult {
                        Text(result)
                            .font(.subheadline)
                            .foregroundColor(result.contains("Success") ? .green : .red)
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Profile")
        }
    }
    
    private func syncData() {
        isSyncing = true
        syncResult = nil

        DispatchQueue.main.asyncAfter(deadline: .now()) {
            isSyncing = false
            syncResult = "Sync Success: Data is up-to-date."
            
            NotificationService.shared.sendNotification(
                title: "Sync Completed",
                body: "Your data is now up-to-date."
            )
        }
    }
    private var logoutButton: some View {
            Button(action: {
                isLoggedIn = false
            }) {
                Text("Log out")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
}

#Preview {
    Profile()
}
