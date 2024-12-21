//
//  WaterStatusController.swift
//  ClearPoolWaterServer
//
//  Created by Stanimir Hristov on 21.10.24.
//

import Vapor
import Fluent

final class WaterStatusController: RouteCollection, @unchecked Sendable {
    func boot(routes: any RoutesBuilder) throws {
        let secure = routes.grouped(
            SessionToken.authenticator(),
            SessionToken.guardMiddleware()
        )
        
        let waterStatus = secure.grouped("api", "waterStatus")
        waterStatus.get(use: index)
        waterStatus.post(use: create)
        
        waterStatus.group(":id") { status in
            status.get(use: show)
            status.put(use: update)
            status.delete(use: delete)
        }
    }
    
    func index(req: Request) async throws -> [WaterStatus] {
        try await WaterStatus.query(on: req.db).all()
    }
    
    func create(req: Request) async throws -> WaterStatus {
        try WaterStatus.Create.validate(content: req)
        
        let create = try req.content.decode(WaterStatus.Create.self)
        
        let waterStatus = WaterStatus(
            ph: create.ph,
            chlorine: create.chlorine,
            alkalinity: create.alkalinity,
            temperature: create.temperature,
            poolID: create.pool
        )
        try await waterStatus.create(on: req.db)
        
        return waterStatus
    }
    
    func show(req: Request) async throws -> WaterStatus {
        let id = try req.parameters.require("id", as: Int.self)
        guard let waterStatus = try await WaterStatus.find(id, on: req.db) else {
            throw Abort(.notFound)
        }
        return waterStatus
    }
    
    func update(req: Request) async throws -> WaterStatus {
        let id = try req.parameters.require("id", as: Int.self)
        guard let waterStatus = try await WaterStatus.find(id, on: req.db) else {
            throw Abort(.notFound)
        }
        
        try WaterStatus.Create.validate(content: req)
                
        let updatedWaterStatus = try req.content.decode(WaterStatus.Create.self)
        waterStatus.ph = updatedWaterStatus.ph
        waterStatus.chlorine = updatedWaterStatus.chlorine
        waterStatus.alkalinity = updatedWaterStatus.alkalinity
        waterStatus.temperature = updatedWaterStatus.temperature

        try await waterStatus.update(on: req.db)
        
        return waterStatus
    }
    
    func delete(req: Request) async throws -> HTTPStatus {
        let id = try req.parameters.require("id", as: Int.self)
        guard let waterStatus = try await WaterStatus.find(id, on: req.db) else {
            throw Abort(.notFound)
        }
        try await waterStatus.delete(on: req.db)
        return .ok
    }
}
