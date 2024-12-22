//
//  CreateWaterStatus.swift
//  ClearPoolWaterServer
//
//  Created by Stanimir Hristov on 19.10.24.
//

import Fluent

extension WaterStatus {
    struct Migration: AsyncMigration {
        var name: String { "CreateWaterStatus" }
        
        func prepare(on database: any Database) async throws {
            try await database.schema("water_status")
                .field("id", .int, .identifier(auto: true))  // Auto-incrementing primary key
                .field("ph", .double, .required)
                .field("chlorine", .double, .required)
                .field("alkalinity", .double)
                .field("temperature", .double)
                .field("created_at", .datetime, .required)
                .field("updated_at", .datetime)
                .field("pool_id", .int, .required, .references("pools", "id", onDelete: .cascade, onUpdate: .cascade))
                .update()
        }
        
        func revert(on database: any Database) async throws {
            try await database.schema("water_status").delete()
        }
    }
}
