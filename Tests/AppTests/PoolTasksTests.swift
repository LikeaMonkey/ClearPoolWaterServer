//
//  PoolTasksTests.swift
//  ClearPoolWaterServer
//
//  Created by Stanimir Hristov on 24.10.24.
//

import Testing
import Foundation
@testable import App

struct PoolTasksTests {
    struct SkimTaskTests {
        @Test func testHighPriority() async {
            let lastTimeDone = DateUtils.date(daysAgo: 8)
            let task = SkimTask(lastTimeDone: lastTimeDone).task
            let expected = PoolTask(code: .skim, priority: .high, type: .cleaning)
            #expect(task == expected)
        }
        
        @Test func testMediumPriority() async {
            let lastTimeDone = DateUtils.date(daysAgo: 6)
            let task = SkimTask(lastTimeDone: lastTimeDone).task
            let expected = PoolTask(code: .skim, priority: .medium, type: .cleaning)
            #expect(task == expected)
        }
        
        @Test func testLowPriority() async {
            let lastTimeDone = DateUtils.date(daysAgo: 3)
            let task = SkimTask(lastTimeDone: lastTimeDone).task
            let expected = PoolTask(code: .skim, priority: .low, type: .cleaning)
            #expect(task == expected)
        }
        
        @Test func testTooSoon() async {
            let lastTimeDone = DateUtils.date(daysAgo: 1)
            let task = SkimTask(lastTimeDone: lastTimeDone).task
            #expect(task == nil)
        }
        
        @Test func testNeverDone() async {
            let task = SkimTask(lastTimeDone: nil).task
            let expected = PoolTask(code: .skim, priority: .pending, type: .cleaning)
            #expect(task == expected)
        }
    }
    
    struct VacuumTaskTests {
        @Test func testHighPriority() async {
            let lastTimeDone = DateUtils.date(daysAgo: 8)
            let task = VacuumTask(lastTimeDone: lastTimeDone).task
            let expected = PoolTask(code: .vacuum, priority: .high, type: .cleaning)
            #expect(task == expected)
        }
        
        @Test func testMediumPriority() async {
            let lastTimeDone = DateUtils.date(daysAgo: 6)
            let task = VacuumTask(lastTimeDone: lastTimeDone).task
            let expected = PoolTask(code: .vacuum, priority: .medium, type: .cleaning)
            #expect(task == expected)
        }
        
        @Test func testLowPriority() async {
            let lastTimeDone = DateUtils.date(daysAgo: 4)
            let task = VacuumTask(lastTimeDone: lastTimeDone).task
            let expected = PoolTask(code: .vacuum, priority: .low, type: .cleaning)
            #expect(task == expected)
        }
        
        @Test func testTooSoon() async {
            let lastTimeDone = DateUtils.date(daysAgo: 1)
            let task = VacuumTask(lastTimeDone: lastTimeDone).task
            #expect(task == nil)
        }
        
        @Test func testNeverDone() async {
            let task = VacuumTask(lastTimeDone: nil).task
            let expected = PoolTask(code: .vacuum, priority: .pending, type: .cleaning)
            #expect(task == expected)
        }
    }
    
    struct BrushTaskTests {
        @Test func testHighPriority() async {
            let lastTimeDone = DateUtils.date(daysAgo: 4)
            let task = BrushTask(lastTimeDone: lastTimeDone).task
            let expected = PoolTask(code: .brush, priority: .high, type: .cleaning)
            #expect(task == expected)
        }
        
        @Test func testMediumPriority() async {
            let lastTimeDone = DateUtils.date(daysAgo: 2)
            let task = BrushTask(lastTimeDone: lastTimeDone).task
            let expected = PoolTask(code: .brush, priority: .medium, type: .cleaning)
            #expect(task == expected)
        }
        
        @Test func testLowPriority() async {
            let lastTimeDone = DateUtils.date(daysAgo: 1)
            let task = BrushTask(lastTimeDone: lastTimeDone).task
            let expected = PoolTask(code: .brush, priority: .low, type: .cleaning)
            #expect(task == expected)
        }
        
        @Test func testTooSoon() async {
            let lastTimeDone = DateUtils.date(daysAgo: 0)
            let task = BrushTask(lastTimeDone: lastTimeDone).task
            #expect(task == nil)
        }
        
        @Test func testNeverDone() async {
            let task = BrushTask(lastTimeDone: nil).task
            let expected = PoolTask(code: .brush, priority: .pending, type: .cleaning)
            #expect(task == expected)
        }
    }
    
    struct EmptyBasketTaskTests {
        @Test func testHighPriority() async {
            let lastTimeDone = DateUtils.date(daysAgo: 11)
            let task = EmptyBasketTask(lastTimeDone: lastTimeDone).task
            let expected = PoolTask(code: .emptyBaskets, priority: .high, type: .cleaning)
            #expect(task == expected)
        }
        
        @Test func testMediumPriority() async {
            let lastTimeDone = DateUtils.date(daysAgo: 7)
            let task = EmptyBasketTask(lastTimeDone: lastTimeDone).task
            let expected = PoolTask(code: .emptyBaskets, priority: .medium, type: .cleaning)
            #expect(task == expected)
        }
        
        @Test func testLowPriority() async {
            let lastTimeDone = DateUtils.date(daysAgo: 3)
            let task = EmptyBasketTask(lastTimeDone: lastTimeDone).task
            let expected = PoolTask(code: .emptyBaskets, priority: .low, type: .cleaning)
            #expect(task == expected)
        }
        
        @Test func testTooSoon() async {
            let lastTimeDone = DateUtils.date(daysAgo: 1)
            let task = EmptyBasketTask(lastTimeDone: lastTimeDone).task
            #expect(task == nil)
        }
        
        @Test func testNeverDone() async {
            let task = EmptyBasketTask(lastTimeDone: nil).task
            let expected = PoolTask(code: .emptyBaskets, priority: .pending, type: .cleaning)
            #expect(task == expected)
        }
    }
    
    struct TestWaterTaskTests {
        @Test func testHighPriority() async {
            let lastTimeDone = DateUtils.date(daysAgo: 4)
            let task = TestWaterTask(lastTimeDone: lastTimeDone).task
            let expected = PoolTask(code: .testWater, priority: .high, type: .testing)
            #expect(task == expected)
        }
        
        @Test func testMediumPriority() async {
            let lastTimeDone = DateUtils.date(daysAgo: 2)
            let task = TestWaterTask(lastTimeDone: lastTimeDone).task
            let expected = PoolTask(code: .testWater, priority: .medium, type: .testing)
            #expect(task == expected)
        }
        
        @Test func testLowPriority() async {
            let lastTimeDone = DateUtils.date(daysAgo: 1)
            let task = TestWaterTask(lastTimeDone: lastTimeDone).task
            let expected = PoolTask(code: .testWater, priority: .low, type: .testing)
            #expect(task == expected)
        }
        
        @Test func testTooSoon() async {
            let lastTimeDone = DateUtils.date(daysAgo: 0)
            let task = TestWaterTask(lastTimeDone: lastTimeDone).task
            #expect(task == nil)
        }
        
        @Test func testNeverDone() async {
            let task = TestWaterTask(lastTimeDone: nil).task
            let expected = PoolTask(code: .testWater, priority: .pending, type: .testing)
            #expect(task == expected)
        }
    }
    
    struct CleanFilterTaskTests {
        @Test func testHighPriority() async {
            let lastTimeDone = DateUtils.date(daysAgo: 15)
            let task = CleanFilterTask(lastTimeDone: lastTimeDone).task
            let expected = PoolTask(code: .cleanFilter, priority: .high, type: .cleaning)
            #expect(task == expected)
        }
        
        @Test func testMediumPriority() async {
            let lastTimeDone = DateUtils.date(daysAgo: 8)
            let task = CleanFilterTask(lastTimeDone: lastTimeDone).task
            let expected = PoolTask(code: .cleanFilter, priority: .medium, type: .cleaning)
            #expect(task == expected)
        }
        
        @Test func testLowPriority() async {
            let lastTimeDone = DateUtils.date(daysAgo: 4)
            let task = CleanFilterTask(lastTimeDone: lastTimeDone).task
            let expected = PoolTask(code: .cleanFilter, priority: .low, type: .cleaning)
            #expect(task == expected)
        }
        
        @Test func testTooSoon() async {
            let lastTimeDone = DateUtils.date(daysAgo: 2)
            let task = CleanFilterTask(lastTimeDone: lastTimeDone).task
            #expect(task == nil)
        }
        
        @Test func testNeverDone() async {
            let task = CleanFilterTask(lastTimeDone: nil).task
            let expected = PoolTask(code: .cleanFilter, priority: .pending, type: .cleaning)
            #expect(task == expected)
        }
    }
    
    struct RunPumpTaskTests {
        @Test func testHighPriority() async {
            let lastTimeDone = DateUtils.date(daysAgo: 3)
            let task = RunPumpTask(lastTimeDone: lastTimeDone).task
            let expected = PoolTask(code: .runPump, priority: .high, type: .maintenance)
            #expect(task == expected)
        }
        
        @Test func testMediumPriority() async {
            let lastTimeDone = DateUtils.date(daysAgo: 2)
            let task = RunPumpTask(lastTimeDone: lastTimeDone).task
            let expected = PoolTask(code: .runPump, priority: .medium, type: .maintenance)
            #expect(task == expected)
        }
        
        @Test func testLowPriority() async {
            let lastTimeDone = DateUtils.date(daysAgo: 1)
            let task = RunPumpTask(lastTimeDone: lastTimeDone).task
            let expected = PoolTask(code: .runPump, priority: .low, type: .maintenance)
            #expect(task == expected)
        }
        
        @Test func testTooSoon() async {
            let lastTimeDone = DateUtils.date(daysAgo: 0)
            let task = RunPumpTask(lastTimeDone: lastTimeDone).task
            #expect(task == nil)
        }
        
        @Test func testNeverDone() async {
            let task = RunPumpTask(lastTimeDone: nil).task
            let expected = PoolTask(code: .runPump, priority: .pending, type: .maintenance)
            #expect(task == expected)
        }
    }
    
    struct InspectTaskTests {
        @Test func testHighPriority() async {
            let lastTimeDone = DateUtils.date(daysAgo: 22)
            let task = InspectTask(lastTimeDone: lastTimeDone).task
            let expected = PoolTask(code: .inspect, priority: .high, type: .maintenance)
            #expect(task == expected)
        }
        
        @Test func testMediumPriority() async {
            let lastTimeDone = DateUtils.date(daysAgo: 15)
            let task = InspectTask(lastTimeDone: lastTimeDone).task
            let expected = PoolTask(code: .inspect, priority: .medium, type: .maintenance)
            #expect(task == expected)
        }
        
        @Test func testLowPriority() async {
            let lastTimeDone = DateUtils.date(daysAgo: 8)
            let task = InspectTask(lastTimeDone: lastTimeDone).task
            let expected = PoolTask(code: .inspect, priority: .low, type: .maintenance)
            #expect(task == expected)
        }
        
        @Test func testTooSoon() async {
            let lastTimeDone = DateUtils.date(daysAgo: 1)
            let task = InspectTask(lastTimeDone: lastTimeDone).task
            #expect(task == nil)
        }
        
        @Test func testNeverDone() async {
            let task = InspectTask(lastTimeDone: nil).task
            let expected = PoolTask(code: .inspect, priority: .pending, type: .maintenance)
            #expect(task == expected)
        }
    }
}
