//
//  PoolTaskCode.swift
//  ClearPoolWaterServer
//
//  Created by Stanimir Hristov on 24.10.24.
//

enum PoolTaskCode: Codable, Equatable {
    /// Water status trait task codes
    case lowPh(diff: Double)
    case highPh(diff: Double)
    case lowChlorine(diff: Double)
    case highChlorine(diff: Double)
    case lowAlkalinity(diff: Double)
    case highAlkalinity(diff: Double)
    case lowTemperature(diff: Double)
    case highTemperature(diff: Double)
    
    /// Pool status task codes
    case skim
    case vacuum
    case brush
    case emptyBaskets
    case testWater
    case cleanFilter
    case runPump
    case inspect
    
    static func == (lhs: PoolTaskCode, rhs: PoolTaskCode) -> Bool {
        switch (lhs, rhs) {
        case (.lowPh(let lhsDiff), .lowPh(let rhsDiff)),
             (.highPh(let lhsDiff), .highPh(let rhsDiff)),
             (.lowChlorine(let lhsDiff), .lowChlorine(let rhsDiff)),
             (.highChlorine(let lhsDiff), .highChlorine(let rhsDiff)),
             (.lowAlkalinity(let lhsDiff), .lowAlkalinity(let rhsDiff)),
             (.highAlkalinity(let lhsDiff), .highAlkalinity(let rhsDiff)),
             (.lowTemperature(let lhsDiff), .lowTemperature(let rhsDiff)),
             (.highTemperature(let lhsDiff), .highTemperature(let rhsDiff)):
            return abs(lhsDiff - rhsDiff) < 0.001 // Acceptable tolerance
        
        case (.skim, .skim),
             (.vacuum, .vacuum),
             (.brush, .brush),
             (.emptyBaskets, .emptyBaskets),
             (.testWater, .testWater),
             (.cleanFilter, .cleanFilter),
             (.runPump, .runPump),
             (.inspect, .inspect):
            return true
        
        default:
            return false
        }
    }
}
