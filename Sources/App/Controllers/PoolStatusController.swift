//
//  PoolStatusController.swift
//  ClearPoolWaterServer
//
//  Created by Stanimir Hristov on 20.10.24.
//

import Vapor
import Fluent

final class PoolStatusController: RouteCollection, @unchecked Sendable {
    func boot(routes: any RoutesBuilder) throws {
        let secure = routes.grouped(
            SessionToken.authenticator(),
            SessionToken.guardMiddleware()
        )
        
        let poolStatus = secure.grouped("api", "poolStatus")
        poolStatus.get(use: index)
        poolStatus.post(use: create)
        
        poolStatus.group(":id") { status in
            status.get(use: show)
            status.put(use: update)
            status.delete(use: delete)
        }
    }
    
    func index(req: Request) async throws -> [PoolStatus] {
        try await PoolStatus.query(on: req.db).all()
    }
    
    func create(req: Request) async throws -> PoolStatus {
        let create = try req.content.decode(PoolStatus.Create.self)
        let poolStatus = PoolStatus(
            skimDate: create.skim ? .now : nil,
            vacuumDate: create.vacuum ? .now : nil,
            brushDate: create.brush ? .now : nil,
            emptyBasketsDate: create.emptyBaskets ? .now : nil,
            testWaterDate: create.testWater ? .now : nil,
            cleanFilterDate: create.cleanFilter ? .now : nil,
            runPumpDate: create.runPump ? .now : nil,
            inspectDate: create.inspect ? .now : nil,
            poolID: create.pool
        )
        try await poolStatus.create(on: req.db)
        return poolStatus
    }
    
    func show(req: Request) async throws -> PoolStatus {
        let id = try req.parameters.require("id", as: Int.self)
        guard let poolStatus = try await PoolStatus.find(id, on: req.db) else {
            throw Abort(.notFound)
        }
        return poolStatus
    }
    
    func update(req: Request) async throws -> PoolStatus {
        let id = try req.parameters.require("id", as: Int.self)
        guard let poolStatus = try await PoolStatus.find(id, on: req.db) else {
            throw Abort(.notFound)
        }
                
        let updatedPoolStatus = try req.content.decode(PoolStatus.Create.self)
        poolStatus.skimDate = updatedPoolStatus.skim ? .now : nil
        poolStatus.vacuumDate = updatedPoolStatus.vacuum ? .now : nil
        poolStatus.brushDate = updatedPoolStatus.brush ? .now : nil
        poolStatus.emptyBasketsDate = updatedPoolStatus.emptyBaskets ? .now : nil
        poolStatus.testWaterDate = updatedPoolStatus.testWater ? .now : nil
        poolStatus.cleanFilterDate = updatedPoolStatus.cleanFilter ? .now : nil
        poolStatus.runPumpDate = updatedPoolStatus.runPump ? .now : nil
        poolStatus.inspectDate = updatedPoolStatus.inspect ? .now : nil

        try await poolStatus.update(on: req.db)
        
        return poolStatus
    }
    
    func delete(req: Request) async throws -> HTTPStatus {
        let id = try req.parameters.require("id", as: Int.self)
        guard let poolStatus = try await PoolStatus.find(id, on: req.db) else {
            throw Abort(.notFound)
        }
        try await poolStatus.delete(on: req.db)
        return .ok
    }
}
