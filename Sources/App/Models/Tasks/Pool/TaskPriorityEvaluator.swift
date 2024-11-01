//
//  TaskPriorityScheduler.swift
//  ClearPoolWaterServer
//
//  Created by Stanimir Hristov on 23.10.24.
//

import Foundation

struct TaskPriorityEvaluator {
    static func evaluate(for date: Date?, schedule: ScheduleRange) -> PoolTaskPriority {
        guard let date else { return .pending }
        
        switch DateUtils.daysBetween(date, .now) {
            case ..<schedule.low:
                return .none
            case schedule.low..<schedule.medium:
                return .low
            case schedule.medium..<schedule.high:
                return .medium
            default:
                return .high
        }
    }
}
