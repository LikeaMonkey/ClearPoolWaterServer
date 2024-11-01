//
//  Untitled.swift
//  ClearPoolWaterServer
//
//  Created by Stanimir Hristov on 23.10.24.
//

import Foundation

struct SkimTask: PoolTaskRepresentable {
    let lastTimeDone: Date?
    var schedule: ScheduleRange {
        ScheduleRange(low: 2, medium: 5, high: 7)
    }
    var taskCode: PoolTaskCode { .skim }
    var taskType: PoolTaskType { .cleaning }
}

struct VacuumTask: PoolTaskRepresentable {
    let lastTimeDone: Date?
    var schedule: ScheduleRange {
        ScheduleRange(low: 3, medium: 5, high: 7)
    }
    var taskCode: PoolTaskCode { .vacuum }
    var taskType: PoolTaskType { .cleaning }
}

struct BrushTask: PoolTaskRepresentable {
    let lastTimeDone: Date?
    var schedule: ScheduleRange {
        ScheduleRange(low: 2, medium: 6, high: 10)
    }
    var taskCode: PoolTaskCode { .brush }
    var taskType: PoolTaskType { .cleaning }
}

struct EmptyBasketTask: PoolTaskRepresentable {
    let lastTimeDone: Date?
    var schedule: ScheduleRange {
        ScheduleRange(low: 2, medium: 6, high: 10)
    }
    var taskCode: PoolTaskCode { .emptyBaskets }
    var taskType: PoolTaskType { .cleaning }
}

struct TestWaterTask: PoolTaskRepresentable {
    let lastTimeDone: Date?
    var schedule: ScheduleRange {
        ScheduleRange(low: 1, medium: 2, high: 3)
    }
    var taskCode: PoolTaskCode { .testWater }
    var taskType: PoolTaskType { .testing }
}

struct CleanFilterTask: PoolTaskRepresentable {
    let lastTimeDone: Date?
    var schedule: ScheduleRange {
        ScheduleRange(low: 3, medium: 7, high: 14)
    }
    var taskCode: PoolTaskCode { .cleanFilter }
    var taskType: PoolTaskType { .cleaning }
}

struct RunPumpTask: PoolTaskRepresentable {
    let lastTimeDone: Date?
    var schedule: ScheduleRange {
        ScheduleRange(low: 1, medium: 2, high: 3)
    }
    var taskCode: PoolTaskCode { .runPump }
    var taskType: PoolTaskType { .maintenance }
}

struct InspectTask: PoolTaskRepresentable {
    let lastTimeDone: Date?
    var schedule: ScheduleRange {
        ScheduleRange(low: 7, medium: 14, high: 21)
    }
    var taskCode: PoolTaskCode { .inspect }
    var taskType: PoolTaskType { .maintenance }
}
