//
//  WaterTraitCheckable.swift
//  ClearPoolWaterServer
//
//  Created by Stanimir Hristov on 23.10.24.
//

enum WaterTraitResult {
    case low, normal, high
}

protocol WaterTraitCheckable {
    var value: Double { get }
    var idealRange: ClosedRange<Double> { get }
    
    func check() -> WaterTraitResult
}

extension WaterTraitCheckable {
    func check() -> WaterTraitResult {
        if value < idealRange.lowerBound {
            return .low
        }
        if value > idealRange.upperBound {
            return .high
        }
        return .normal
    }
}
