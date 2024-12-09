//
//  Date.swift
//  MoneyCheck
//
//  Created by Максим Билык on 09.12.2024.
//

import Foundation

extension Date {
    func isSameDay(as otherDate: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(self, inSameDayAs: otherDate)
    }
}
