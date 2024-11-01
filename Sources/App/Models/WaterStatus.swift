//
//  WaterStatus.swift
//  ClearPoolWaterServer
//
//  Created by Stanimir Hristov on 19.10.24.
//

import Vapor
import Fluent

final class WaterStatus: Model, Content, @unchecked Sendable {
    static let schema = "water_status"
    
    @ID(custom: "id", generatedBy: .database)
    var id: Int?
    
    @Field(key: "ph")
    var ph: Double
    
    @Field(key: "chlorine")
    var chlorine: Double
    
    @OptionalField(key: "alkalinity")
    var alkalinity: Double?
    
    @OptionalField(key: "temperature")
    var temperature: Double?
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    @Parent(key: "pool_id")
    var pool: Pool
        
    init() {}
    
    init(
        id: Int? = nil,
        ph: Double = 7.2,
        chlorine: Double = 1.0,
        alkalinity: Double? = nil,
        temperature: Double? = nil,
        createdAt: Date? = nil,
        updatedAt: Date? = nil,
        poolID: Pool.IDValue
    ) {
        self.id = id
        self.ph = ph
        self.chlorine = chlorine
        self.alkalinity = alkalinity
        self.temperature = temperature
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.$pool.id = poolID
    }
}

extension WaterStatus {
    struct Create: Content {
        var ph: Double
        var chlorine: Double
        var alkalinity: Double?
        var temperature: Double?
        var pool: Pool.IDValue
    }
}

extension WaterStatus.Create: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("ph", as: Double.self, is: .range(0...14))
        validations.add("chlorine", as: Double.self, is: .range(0...10))
        validations.add("alkalinity", as: Double.self, is: .range(0...300))
        validations.add("temperature", as: Double.self, is: .range(0...100))
    }
}
