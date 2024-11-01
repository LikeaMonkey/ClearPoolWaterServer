//
//  PoolTaskPriority.swift
//  ClearPoolWaterServer
//
//  Created by Stanimir Hristov on 24.10.24.
//

enum PoolTaskPriority: String, Codable, Equatable {
    case none, pending, low, medium, high
}
