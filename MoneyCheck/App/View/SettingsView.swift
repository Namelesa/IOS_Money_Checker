//
//  SettingsView.swift
//  MoneyCheck
//
//  Created by Максим Билык on 26.09.2024.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("salary") private var salary: Double = 0

    var body: some View {
        ScrollView(.vertical, showsIndicators: false){
            VStack {
                Text("Settings")
                    .font(.largeTitle)
                    .padding()

                Button(action: {
                    salary = 0
                }) {
                    Text("Reset salary")
                        .font(.title2)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
    }
}
