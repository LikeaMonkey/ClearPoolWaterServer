//
//  TaskPriorityEvaluatorTests.swift
//  ClearPoolWaterServer
//
//  Created by Stanimir Hristov on 24.10.24.
//

import Testing
@testable import App

struct TaskPriorityEvaluatorTests {
    let schedule = ScheduleRange(low: 2, medium: 5, high: 7)
    
    @Test func testEvaluatePending() async {
        let result = TaskPriorityEvaluator.evaluate(for: nil, schedule: schedule)
        #expect(result == .pending)
    }
    
    @Test func testEvaluateNone() async {
        let date = DateUtils.date(daysAgo: 1)
        let result = TaskPriorityEvaluator.evaluate(for: date, schedule: schedule)
        #expect(result == .none)
    }
    
    @Test func testEvaluateLowPriority() async {
        let date = DateUtils.date(daysAgo: 3)
        let result = TaskPriorityEvaluator.evaluate(for: date, schedule: schedule)
        #expect(result == .low)
    }
    
    @Test func testEvaluateMediumPriority() async {
        let date = DateUtils.date(daysAgo: 6)
        let result = TaskPriorityEvaluator.evaluate(for: date, schedule: schedule)
        #expect(result == .medium)
    }
    
    @Test func testEvaluateHighPriority() async {
        let date = DateUtils.date(daysAgo: 8)
        let result = TaskPriorityEvaluator.evaluate(for: date, schedule: schedule)
        #expect(result == .high)
    }
}
