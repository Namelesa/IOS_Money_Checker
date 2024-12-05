//
//  Income.swift
//  MoneyCheck
//
//  Created by Максим Билык on 03.12.2024.
//
import SwiftUI
import Charts

struct Income: Identifiable {
    let id = UUID()
    let date: Date
    let source: String
    let amount: Double
}
