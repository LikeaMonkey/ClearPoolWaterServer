//
//  PoolTasksManagerTests.swift
//  ClearPoolWaterServer
//
//  Created by Stanimir Hristov on 24.10.24.
//

import Testing
@testable import App

struct PoolTasksManagerTests {
    @Test func testNoWaterStatusTasks() async {
        let waterStatus = WaterStatus(poolID: 1)
        let tasks = PoolTasksManager.tasks(for: waterStatus)
        #expect(tasks.isEmpty)
    }
    
    @Test func testPartialWaterStatusTasks() async {
        let waterStatus = WaterStatus(ph: 6.8, chlorine: 0.5, poolID: 1)
        let tasks = PoolTasksManager.tasks(for: waterStatus)
        #expect(tasks.count == 2)
    }
    
    @Test func testAllWaterStatusTasks() async {
        let waterStatus = WaterStatus(ph: 6.8, chlorine: 0.5, alkalinity: 70, temperature: 21, poolID: 1)
        let tasks = PoolTasksManager.tasks(for: waterStatus)
        #expect(tasks.count == 4)
    }
    
    @Test func testNoPoolStatusTasks() async {
        let poolStatus = PoolStatus(
            skimDate: .now,
            vacuumDate: .now,
            brushDate: .now,
            emptyBasketsDate: .now,
            testWaterDate: .now,
            cleanFilterDate: .now,
            runPumpDate: .now,
            inspectDate: .now,
            poolID: 1
        )
        let tasks = PoolTasksManager.tasks(for: poolStatus)
        #expect(tasks.isEmpty)
    }
    
    @Test func testPartialPoolStatusTasks() async {
        let poolStatus = PoolStatus(skimDate: .now, vacuumDate: .now, poolID: 1)
        let tasks = PoolTasksManager.tasks(for: poolStatus)
        #expect(tasks.count == 6)
    }
    
    @Test func testAllPoolStatusTasks() async {
        let poolStatus = PoolStatus(poolID: 1)
        let tasks = PoolTasksManager.tasks(for: poolStatus)
        #expect(tasks.count == 8)
    }
    
    @Test func testNoTasks() async {
        let waterStatus = WaterStatus(poolID: 1)
        let poolStatus = PoolStatus(
            skimDate: .now,
            vacuumDate: .now,
            brushDate: .now,
            emptyBasketsDate: .now,
            testWaterDate: .now,
            cleanFilterDate: .now,
            runPumpDate: .now,
            inspectDate: .now,
            poolID: 1
        )
        let tasks = PoolTasksManager.tasks(waterStatus: waterStatus, poolStatus: poolStatus)
        #expect(tasks.isEmpty)
    }
    
    @Test func testPartialTasks() async {
        let waterStatus = WaterStatus(ph: 6.8, chlorine: 0.5, poolID: 1)
        let poolStatus = PoolStatus(skimDate: .now, vacuumDate: .now, poolID: 1)
        let tasks = PoolTasksManager.tasks(waterStatus: waterStatus, poolStatus: poolStatus)
        #expect(tasks.count == 8)
    }
    
    @Test func testAllTasks() async {
        let waterStatus = WaterStatus(ph: 6.8, chlorine: 0.5, alkalinity: 70, temperature: 21, poolID: 1)
        let poolStatus = PoolStatus(poolID: 1)
        let tasks = PoolTasksManager.tasks(waterStatus: waterStatus, poolStatus: poolStatus)
        #expect(tasks.count == 12)
    }
}
