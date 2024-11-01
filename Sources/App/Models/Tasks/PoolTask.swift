//
//  PoolTask.swift
//  ClearPoolWaterServer
//
//  Created by Stanimir Hristov on 23.10.24.
//

import Vapor

struct PoolTask: Content, Equatable {
    var code: PoolTaskCode
    var priority: PoolTaskPriority
    var type: PoolTaskType
}
