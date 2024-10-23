//
//  CreateUser.swift
//  ClearPoolWaterServer
//
//  Created by Stanimir Hristov on 9.10.24.
//

import Fluent

extension User {
    struct Migration: AsyncMigration {
        var name: String { "CreateUser" }
        
        func prepare(on database: any Database) async throws {
            try await database.schema("users")
                .field("id", .int, .identifier(auto: true))  // Auto-incrementing primary key
                .field("email", .string, .required)
                .field("password_hash", .string, .required)
                .field("role", .string, .required)
                .field("created_at", .datetime, .required)
                .field("updated_at", .datetime)
                .field("last_login", .datetime)
                .unique(on: "email")
                .create()
        }
        
        func revert(on database: any Database) async throws {
            try await database.schema("users").delete()
        }
    }
}
