//
//  WaterTasksTests.swift
//  ClearPoolWaterServer
//
//  Created by Stanimir Hristov on 24.10.24.
//

import Testing
@testable import App

struct WaterTasksTests {
    struct PhTaskTests {
        @Test func testNormalLevel() async {
            let task = PhTask(value: 7.4)
            #expect(task.create() == nil)
        }
        
        @Test func testLowLevel() async {
            let task = PhTask(value: 6.8)
            let expected = PoolTask(code: .lowPh(diff: 0.4), priority: .high, type: .maintenance)
            #expect(task.create() == expected)
        }
        
        @Test func testHighLevel() async {
            let task = PhTask(value: 7.8)
            let expected = PoolTask(code: .highPh(diff: 0.2), priority: .high, type: .maintenance)
            #expect(task.create() == expected)
        }
        
        @Test func testLowerBoundLevel() async {
            let task = PhTask(value: 7.2)
            #expect(task.create() == nil)
        }
        
        @Test func testUpperBoundLevel() async {
            let task = PhTask(value: 7.6)
            #expect(task.create() == nil)
        }
    }
    
    struct ChlorineTaskTests {
        @Test func testNormalLevel() async {
            let task = ChlorineTask(value: 1.5)
            #expect(task.create() == nil)
        }
        
        @Test func testLowLevel() async {
            let task = ChlorineTask(value: 0.5)
            let expected = PoolTask(code: .lowChlorine(diff: 0.5), priority: .high, type: .maintenance)
            #expect(task.create() == expected)
        }
        
        @Test func testHighLevel() async {
            let task = ChlorineTask(value: 4)
            let expected = PoolTask(code: .highChlorine(diff: 1), priority: .high, type: .maintenance)
            #expect(task.create() == expected)
        }
        
        @Test func testLowerBoundLevel() async {
            let task = ChlorineTask(value: 1)
            #expect(task.create() == nil)
        }
        
        @Test func testUpperBoundLevel() async {
            let task = ChlorineTask(value: 3)
            #expect(task.create() == nil)
        }
    }
    
    struct AlkalinityTaskTests {
        @Test func testNormalLevel() async {
            let task = AlkalinityTask(value: 100)
            #expect(task.create() == nil)
        }
        
        @Test func testLowLevel() async {
            let task = AlkalinityTask(value: 60)
            let expected = PoolTask(code: .lowAlkalinity(diff: 20), priority: .high, type: .maintenance)
            #expect(task.create() == expected)
        }
        
        @Test func testHighLevel() async {
            let task = AlkalinityTask(value: 150)
            let expected = PoolTask(code: .highAlkalinity(diff: 30), priority: .high, type: .maintenance)
            #expect(task.create() == expected)
        }
        
        @Test func testLowerBoundLevel() async {
            let task = AlkalinityTask(value: 80)
            #expect(task.create() == nil)
        }
        
        @Test func testUpperBoundLevel() async {
            let task = AlkalinityTask(value: 120)
            #expect(task.create() == nil)
        }
    }
    
    struct TemperatureTaskTests {
        @Test func testNormalLevel() async {
            let task = TemperatureTask(value: 27)
            #expect(task.create() == nil)
        }
        
        @Test func testLowLevel() async {
            let task = TemperatureTask(value: 20)
            let expected = PoolTask(code: .lowTemperature(diff: 5), priority: .low, type: .maintenance)
            #expect(task.create() == expected)
        }
        
        @Test func testHighLevel() async {
            let task = TemperatureTask(value: 30)
            let expected = PoolTask(code: .highTemperature(diff: 2), priority: .low, type: .maintenance)
            #expect(task.create() == expected)
        }
        
        @Test func testLowerBoundLevel() async {
            let task = TemperatureTask(value: 25)
            #expect(task.create() == nil)
        }
        
        @Test func testUpperBoundLevel() async {
            let task = TemperatureTask(value: 28)
            #expect(task.create() == nil)
        }
    }
}
