//
//  CreatePoolStatus.swift
//  ClearPoolWaterServer
//
//  Created by Stanimir Hristov on 20.10.24.
//

import Fluent

extension PoolStatus {
    struct Migration: AsyncMigration {
        var name: String { "CreatePoolStatus" }
        
        func prepare(on database: any Database) async throws {
            try await database.schema("pool_status")
                .field("id", .int, .identifier(auto: true))  // Auto-incrementing primary key
                .field("skim_date", .date)
                .field("vacuum_date", .date)
                .field("brush_date", .date)
                .field("empty_baskets_date", .date)
                .field("test_water_date", .date)
                .field("clean_filter_date", .date)
                .field("run_pump_date", .date)
                .field("inspect_date", .date)
                .field("created_at", .datetime, .required)
                .field("updated_at", .datetime)
                .field("pool_id", .int, .required, .references("pools", "id", onDelete: .cascade, onUpdate: .cascade))
                .create()
        }
        
        func revert(on database: any Database) async throws {
            try await database.schema("pool_status").delete()
        }
    }
}
