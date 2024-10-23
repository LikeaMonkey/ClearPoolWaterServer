//
//  PoolStatus.swift
//  ClearPoolWaterServer
//
//  Created by Stanimir Hristov on 20.10.24.
//

import Vapor
import Fluent

final class PoolStatus: Model, Content, @unchecked Sendable {
    static let schema = "pool_status"
    
    @ID(custom: "id", generatedBy: .database)
    var id: Int?
    
    @OptionalField(key: "skim_date")
    var skimDate: Date?
    
    @OptionalField(key: "vacuum_date")
    var vacuumDate: Date?
    
    @OptionalField(key: "brush_date")
    var brushDate: Date?
        
    @OptionalField(key: "empty_baskets_date")
    var emptyBasketsDate: Date?
    
    @OptionalField(key: "test_water_date")
    var testWaterDate: Date?
    
    @OptionalField(key: "clean_filter_date")
    var cleanFilterDate: Date?
    
    @OptionalField(key: "run_pump_date")
    var runPumpDate: Date?
    
    @OptionalField(key: "inspect_date")
    var inspectDate: Date?
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    @Parent(key: "pool_id")
    var pool: Pool
        
    init() {}
    
    init(
        id: Int? = nil,
        skimDate: Date? = nil,
        vacuumDate: Date? = nil,
        brushDate: Date? = nil,
        emptyBasketsDate: Date? = nil,
        testWaterDate: Date? = nil,
        cleanFilterDate: Date? = nil,
        runPumpDate: Date? = nil,
        inspectDate: Date? = nil,
        createdAt: Date? = nil,
        updatedAt: Date? = nil,
        poolID: Pool.IDValue
    ) {
        self.id = id
        self.skimDate = skimDate
        self.vacuumDate = vacuumDate
        self.brushDate = brushDate
        self.emptyBasketsDate = emptyBasketsDate
        self.testWaterDate = testWaterDate
        self.cleanFilterDate = cleanFilterDate
        self.runPumpDate = runPumpDate
        self.inspectDate = inspectDate
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.$pool.id = poolID
    }
}

extension PoolStatus {
    struct Create: Content {
        var skim = false
        var vacuum = false
        var brush = false
        var emptyBaskets = false
        var testWater = false
        var cleanFilter = false
        var runPump = false
        var inspect = false
        var pool: Pool.IDValue
    }
}
