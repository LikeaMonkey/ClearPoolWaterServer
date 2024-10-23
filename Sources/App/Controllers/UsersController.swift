//
//  UsersController.swift
//  ClearPoolWaterServer
//
//  Created by Stanimir Hristov on 9.10.24.
//

import Vapor

final class UsersController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let userRoutes = routes.grouped("api", "users")
        userRoutes.post(use: createUser)
        userRoutes.get(use: getAllUsers)
        userRoutes.get(":id", use: getUser)
    }
    
    func createUser(request: Request) async throws -> User {
        try User.Create.validate(content: request)
        
        let create = try request.content.decode(User.Create.self)
        guard create.password == create.confirmPassword else {
            throw Abort(.badRequest, reason: "Passwords do not match")
        }
        
        let user = try User(
            email: create.email,
            passwordHash: Bcrypt.hash(create.password),
            role: create.role
        )
        try await user.save(on: request.db)
        
        return user
    }
    
    func getAllUsers(request: Request) async throws -> [User] {
        try await User.query(on: request.db).all()
    }
    
    func getUser(request: Request) async throws -> User {
        let id = try request.parameters.require("id", as: Int.self)
        guard let user = try await User.find(id, on: request.db) else {
            throw Abort(.notFound)
        }
        
        return user
    }
}
