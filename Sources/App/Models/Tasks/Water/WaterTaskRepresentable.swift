//
//  Untitled.swift
//  ClearPoolWaterServer
//
//  Created by Stanimir Hristov on 23.10.24.
//

protocol WaterTaskRepresentable: WaterTraitCheckable {
    func create() -> PoolTask?
    
    var priority: PoolTaskPriority { get }
    var lowCode: PoolTaskCode { get }
    var highCode: PoolTaskCode { get }
}

extension WaterTaskRepresentable {
    func create() -> PoolTask? {
        let check = check()
        switch check {
        case .normal:
            return nil
        case .low:
            return PoolTask(code: lowCode, priority: priority, type: .maintenance)
        case .high:
            return PoolTask(code: highCode, priority: priority, type: .maintenance)
        }
    }
}
