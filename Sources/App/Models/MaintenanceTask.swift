//
//  MaintenanceTask.swift
//  ClearPoolWaterServer
//
//  Created by Stanimir Hristov on 19.10.24.
//

import Vapor
import Fluent

final class MaintenanceTask: Model, Content, @unchecked Sendable {
    static let schema = "maintenance_tasks"
    
    @ID(custom: "id", generatedBy: .database)
    var id: Int?
    
    @Field(key: "description")
    var description: String
    
    @Enum(key: "priority")
    var priority: Priority
    
    @Enum(key: "type")
    var type: `Type`
    
    @Enum(key: "status")
    var status: Status
    
    @Field(key: "suggested_time")
    var suggestedTime: Date
    
    @Field(key: "completed_time")
    var completedTime: Date?
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    @Parent(key: "pool_id")
    var pool: Pool
        
    init() {}
    
    init(
        id: Int? = nil,
        description: String,
        priority: Priority,
        type: `Type`,
        status: Status,
        suggestedTime: Date,
        completedTime: Date? = nil,
        createdAt: Date? = nil,
        updatedAt: Date? = nil,
        poolID: Pool.IDValue
    ) {
        self.id = id
        self.description = description
        self.priority = priority
        self.type = type
        self.status = status
        self.suggestedTime = suggestedTime
        self.completedTime = completedTime
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.$pool.id = poolID
    }
}

extension MaintenanceTask {
    enum Priority: String, Codable {
        case low, medium, high
    }
    
    enum `Type`: String, Codable {
        case maintenance, cleaning, testing
    }
    
    enum Status: String, Codable {
        case open, pending, completed, skipped
    }
}

extension MaintenanceTask {
    struct Create: Content {
        var descriptio: String
        var priority: Priority
        var type: `Type`
        var status: Status
        var suggestedTime: Date
        var completedTime: Data?
        var pool: Pool.IDValue
    }
}

// TODO: Add validations for MaintenanceTask
//extension MaintenanceTask.Create: Validatable {
//    static func validations(_ validations: inout Validations) {
//        validations.add("ph", as: String.self, is: .count(0...14))
//    }
//}
