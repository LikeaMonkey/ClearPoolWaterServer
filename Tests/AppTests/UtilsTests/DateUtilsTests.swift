//
//  DateUtilsTests.swift
//  ClearPoolWaterServer
//
//  Created by Stanimir Hristov on 24.10.24.
//

import Testing
@testable import App

struct DateUtilsTests {
    @Test func testDaysBetweenNormalDates() async {
        let startDate = DateUtils.date(day: 1, month: 1, year: 2024)!
        let endDate = DateUtils.date(day: 10, month: 1, year: 2024)!

        let days = DateUtils.daysBetween(startDate, endDate)
        #expect(days == 9)
    }
    
    @Test func testDaysBetweenSameDay() async {
        let date = DateUtils.date(day: 1, month: 1, year: 2024)!

        let days = DateUtils.daysBetween(date, date)
        #expect(days == 0)
    }
    
    @Test func testDaysBetweenLeapYear() async {
        // Leap year
        let startDate = DateUtils.date(day: 28, month: 2, year: 2024)!
        let endDate = DateUtils.date(day: 1, month: 3, year: 2024)!

        let days = DateUtils.daysBetween(startDate, endDate)
        #expect(days == 2)
    }
    
    @Test func testDaysAcrossDaylightSavingTime() async {
        // Assuming daylight saving time starts on March 10, 2024 in the US
        let startDate = DateUtils.date(day: 9, month: 3, year: 2024)!
        let endDate = DateUtils.date(day: 11, month: 3, year: 2024)!

        let days = DateUtils.daysBetween(startDate, endDate)
        #expect(days == 2)
    }
    
    @Test func testDaysBetweenNegativeDateRange() async {
        let startDate = DateUtils.date(day: 10, month: 3, year: 2024)!
        let endDate = DateUtils.date(day: 9, month: 3, year: 2024)!

        let days = DateUtils.daysBetween(startDate, endDate)
        #expect(days == -1)
    }
    
    @Test func testDaysBetweenInlavid() async {
        let startDate = DateUtils.date(day: 10, month: 3, year: 2024)!
        let endDate = DateUtils.date(day: 9, month: 3, year: 2024)!

        let days = DateUtils.daysBetween(startDate, endDate)
        #expect(days == -1)
    }
}
