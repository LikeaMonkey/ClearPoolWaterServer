//
//  User.swift
//  ClearPoolWaterServer
//
//  Created by Stanimir Hristov on 9.10.24.
//

import Vapor
import Fluent

final class User: Model, Content, @unchecked Sendable {
    static let schema = "users"
    
    // Auto-incrementing integer primary key generated by the database
    @ID(custom: "id", generatedBy: .database)
    var id: Int?

    @Field(key: "email")
    var email: String
    
    @Field(key: "password_hash")
    var passwordHash: String
    
    @Enum(key: "role")
    var role: Role
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    @OptionalField(key: "last_login")
    var lastLogin: Date?
    
    init() {}
    
    init(
        id: Int? = nil,
        email: String,
        passwordHash: String,
        role: Role = .user,
        createdAt: Date? = nil,
        updatedAt: Date? = nil,
        lastLogin: Date? = nil
    ) {
        self.id = id
        self.email = email
        self.passwordHash = passwordHash
        self.role = role
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.lastLogin = lastLogin
    }
}

extension User {
    enum Role: String, Codable {
        case admin, user, paidUser = "paid_user"
    }
}

extension User {
    struct Create: Content {
        var email: String
        var password: String
        var confirmPassword: String
        var role: Role
    }
}

extension User.Create: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("email", as: String.self, is: .email)
        validations.add("password", as: String.self, is: .count(8...))
    }
}

extension User: ModelAuthenticatable {
    static let usernameKey = \User.$email
    static let passwordHashKey = \User.$passwordHash

    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.passwordHash)
    }
}

extension User {
    func generateToken() throws -> UserToken {
        let value = [UInt8].random(count: 16).base64
        return try UserToken(value: value, userID: requireID())
    }
}