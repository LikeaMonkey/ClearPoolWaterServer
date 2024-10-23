//
//  CreateUserToken.swift
//  ClearPoolWaterServer
//
//  Created by Stanimir Hristov on 10.10.24.
//

import Fluent

extension UserToken {
    struct Migration: AsyncMigration {
        var name: String { "CreateUserToken" }

        func prepare(on database: any Database) async throws {
            try await database.schema("user_tokens")
                .field("id", .int, .identifier(auto: true))  // Auto-incrementing primary key
                .field("value", .string, .required)
                .field("user_id", .int, .required, .references("users", "id"))
                .unique(on: "value")
                .create()
        }

        func revert(on database: any Database) async throws {
            try await database.schema("user_tokens").delete()
        }
    }
}
