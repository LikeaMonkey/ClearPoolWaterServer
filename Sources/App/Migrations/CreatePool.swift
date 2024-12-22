//
//  CreatePool.swift
//  ClearPoolWaterServer
//
//  Created by Stanimir Hristov on 14.10.24.
//

import Fluent

extension Pool {
    struct Migration: AsyncMigration {
        var name: String { "CreatePool" }
        
        func prepare(on database: any Database) async throws {
            try await database.schema("pools")
                .field("id", .int, .identifier(auto: true))  // Auto-incrementing primary key
                .field("name", .string, .required)
                .field("water_level", .double, .required)
                .field("water_capacity", .double, .required)
                .field("filter_type", .string, .required)
                .field("created_at", .datetime, .required)
                .field("updated_at", .datetime)
                .field("user_id", .int, .required, .references("users", "id", onDelete: .cascade, onUpdate: .cascade))
                .create()
        }
        
        func revert(on database: any Database) async throws {
            try await database.schema("pools").delete()
        }
    }
}

