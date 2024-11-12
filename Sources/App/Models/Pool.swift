//
//  Pool.swift
//  ClearPoolWaterServer
//
//  Created by Stanimir Hristov on 14.10.24.
//

import Vapor
import Fluent

final class Pool: Model, Content, @unchecked Sendable {
    static let schema = "pools"
    
    @ID(custom: "id", generatedBy: .database)
    var id: Int?

    @Field(key: "name")
    var name: String
    
    @Field(key: "water_level")
    var waterLevel: Double
    
    @Field(key: "water_capacity")
    var waterCapacity: Double
    
    @Enum(key: "filter_type")
    var filterType: FilterType
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    @Parent(key: "user_id")
    var user: User
        
    init() {}
    
    init(
        id: Int? = nil,
        name: String,
        waterLevel: Double,
        waterCapacity: Double,
        filterType: FilterType,
        createdAt: Date? = nil,
        updatedAt: Date? = nil,
        userID: User.IDValue
    ) {
        self.id = id
        self.name = name
        self.waterLevel = waterLevel
        self.waterCapacity = waterCapacity
        self.filterType = filterType
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.$user.id = userID
    }
}

extension Pool {
    enum FilterType: String, Codable {
        case sand, cartridge, de // Diatomaceous Earth (DE)
    }
}

extension Pool {
    struct Create: Content {
        var name: String
        var waterLevel: Double
        var waterCapacity: Double
        var filterType: FilterType
    }
}

extension Pool.Create: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("name", as: String.self, is: .count(1...30))
        validations.add("waterLevel", as: Double.self, is: .range(0...1))
        validations.add("waterCapacity", as: Double.self, is: .range(0...))
    }
}
