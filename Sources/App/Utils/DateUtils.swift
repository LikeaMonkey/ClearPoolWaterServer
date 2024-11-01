//
//  DateUtils.swift
//  ClearPoolWaterServer
//
//  Created by Stanimir Hristov on 23.10.24.
//

import Foundation

struct DateUtils {
    static func daysBetween(_ start: Date, _ end: Date) -> Int {
        Calendar.current.dateComponents([.day], from: start, to: end).day!
    }
    
    static func date(day: Int, month: Int, year: Int) -> Date? {
        let components = DateComponents(year: year, month: month, day: day)
        return Calendar.current.date(from: components)
    }
    
    static func date(daysAgo: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date())!
    }
    
    static func isSameDay(_ date1: Date, _ date2: Date) -> Bool {
        Calendar.current.isDate(date1, inSameDayAs: date2)
    }
}
