//
//  PoolTaskRepresentable.swift
//  ClearPoolWaterServer
//
//  Created by Stanimir Hristov on 23.10.24.
//

import Foundation

protocol PoolTaskRepresentable {
    var lastTimeDone: Date? { get }
    var schedule: ScheduleRange { get }
    var taskCode: PoolTaskCode { get }
    var taskType: PoolTaskType { get }
}

extension PoolTaskRepresentable {
    var task: PoolTask? {
        let priority = TaskPriorityEvaluator.evaluate(for: lastTimeDone, schedule: schedule)
        if priority == .none {
            // No task is created if it’s too soon
            return nil
        }
        
        return PoolTask(code: taskCode, priority: priority, type: taskType)
    }
}
