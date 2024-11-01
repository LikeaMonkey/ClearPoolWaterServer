//
//  WaterTasks.swift
//  ClearPoolWaterServer
//
//  Created by Stanimir Hristov on 23.10.24.
//

struct PhTask: WaterTaskRepresentable {
    let value: Double
    var idealRange: ClosedRange<Double> { 7.2...7.6 }
    
    var priority: PoolTaskPriority { .high }
    var lowCode: PoolTaskCode {
        .lowPh(diff: idealRange.lowerBound - value)
    }
    var highCode: PoolTaskCode {
        .highPh(diff: value - idealRange.upperBound)
    }
}

struct ChlorineTask: WaterTaskRepresentable {
    let value: Double
    var idealRange: ClosedRange<Double> { 1...3 }
    
    var priority: PoolTaskPriority { .high }
    var lowCode: PoolTaskCode {
        .lowChlorine(diff: idealRange.lowerBound - value)
    }
    var highCode: PoolTaskCode {
        .highChlorine(diff: value - idealRange.upperBound)
    }
}

struct AlkalinityTask: WaterTaskRepresentable {
    let value: Double
    var idealRange: ClosedRange<Double> { 80...120 }
    
    var priority: PoolTaskPriority { .high }
    var lowCode: PoolTaskCode {
        .lowAlkalinity(diff: idealRange.lowerBound - value)
    }
    var highCode: PoolTaskCode {
        .highAlkalinity(diff: value - idealRange.upperBound)
    }
}

struct TemperatureTask: WaterTaskRepresentable {
    let value: Double
    var idealRange: ClosedRange<Double> { 25...28 }
    
    var priority: PoolTaskPriority { .low }
    var lowCode: PoolTaskCode {
        .lowTemperature(diff: idealRange.lowerBound - value)
    }
    var highCode: PoolTaskCode {
        .highTemperature(diff: value - idealRange.upperBound)
    }
}
