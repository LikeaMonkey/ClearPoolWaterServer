//
//  CreateMaintenanceTask.swift
//  ClearPoolWaterServer
//
//  Created by Stanimir Hristov on 19.10.24.
//

import Fluent

extension MaintenanceTask {
    struct Migration: AsyncMigration {
        var name: String { "CreateMaintenanceTask" }
        
        func prepare(on database: any Database) async throws {
            try await database.schema("maintenance_tasks")
                .field("id", .int, .identifier(auto: true))  // Auto-incrementing primary key
                .field("description", .string, .required)
                .field("priority", .string, .required)
                .field("type", .string, .required)
                .field("status", .string, .required)
                .field("suggestedTime", .datetime, .required)
                .field("completedTime", .datetime)
                .field("created_at", .datetime, .required)
                .field("updated_at", .datetime)
                .field("pool_id", .int, .required, .references("pools", "id"))
                .create()
        }
        
        func revert(on database: any Database) async throws {
            try await database.schema("maintenance_tasks").delete()
        }
    }
}
