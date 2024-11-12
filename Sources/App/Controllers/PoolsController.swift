//
//  PoolsController.swift
//  ClearPoolWaterServer
//
//  Created by Stanimir Hristov on 14.10.24.
//

import Vapor
import Fluent

final class PoolsController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let secure = routes.grouped(
            SessionToken.authenticator(),
            SessionToken.guardMiddleware()
        )

        let pools = secure.grouped("api", "pools")
        pools.get(use: getPools)
        pools.post(use: createPool)
        
        let pool = pools.grouped(":id")
        pool.get(use: getPool)
        pool.put(use: updatePool)
        pool.delete(use: deletePool)
            
        pool.group("poolStatus") { poolStatus in
            poolStatus.get(use: getPoolStatus)
        }
            
        pool.group("waterStatus") { waterStatus in
            waterStatus.get(use: getWaterStatus)
        }
        
        pool.group("tasks") { tasks in
            tasks.get(use: getPoolTasks)
        }
    }
    
    func getPools(req: Request) async throws -> [Pool] {
        let token = try req.auth.require(SessionToken.self)
        let pools = try await Pool.query(on: req.db)
            .filter(\.$user.$id == token.userId)
            .all()
        return pools
    }
    
    func createPool(req: Request) async throws -> Pool {
        let token = try req.auth.require(SessionToken.self)

        try Pool.Create.validate(content: req)
        
        let create = try req.content.decode(Pool.Create.self)
        
        let pool = Pool(
            name: create.name,
            waterLevel: create.waterLevel,
            waterCapacity: create.waterCapacity,
            filterType: create.filterType,
            userID: token.userId
        )
        
        try await pool.create(on: req.db)
        
        let poolStatus = PoolStatus(poolID: pool.id!)
        let waterStatus = WaterStatus(poolID: pool.id!)
        
        try await withThrowingTaskGroup(of: Void.self) { group in
            group.addTask {
                try await poolStatus.create(on: req.db)
            }
            group.addTask {
                try await waterStatus.create(on: req.db)
            }
            
            try await group.waitForAll()
        }

        return pool
    }
    
    func getPool(req: Request) async throws -> Pool {
        let id = try req.parameters.require("id", as: Int.self)
        guard let pool = try await Pool.find(id, on: req.db) else {
            throw Abort(.notFound)
        }
        return pool
    }
    
    func updatePool(req: Request) async throws -> Pool {
        let id = try req.parameters.require("id", as: Int.self)
        guard let pool = try await Pool.find(id, on: req.db) else {
            throw Abort(.notFound)
        }
        
        try Pool.Create.validate(content: req)
        
        let updatedPool = try req.content.decode(Pool.Create.self)
        pool.name = updatedPool.name
        pool.waterLevel = updatedPool.waterLevel
        pool.waterCapacity = updatedPool.waterCapacity
        pool.filterType = updatedPool.filterType
        pool.waterLevel = updatedPool.waterLevel

        try await pool.update(on: req.db)
        
        return pool
    }
    
    func deletePool(req: Request) async throws -> HTTPStatus {
        let id = try req.parameters.require("id", as: Int.self)
        guard let pool = try await Pool.find(id, on: req.db) else {
            throw Abort(.notFound)
        }
        try await pool.delete(on: req.db)
        return .ok
    }
    
    func getPoolStatus(req: Request) async throws -> PoolStatus {
        let id = try req.parameters.require("id", as: Int.self)
        guard let poolStatus = try await PoolStatus.query(on: req.db)
            .filter(\.$pool.$id == id)
            .first()
        else {
            throw Abort(.notFound)
        }
        return poolStatus
    }
    
    func getWaterStatus(req: Request) async throws -> WaterStatus {
        let id = try req.parameters.require("id", as: Int.self)
        guard let waterStatus = try await WaterStatus.query(on: req.db)
            .filter(\.$pool.$id == id)
            .first()
        else {
            throw Abort(.notFound)
        }
        return waterStatus
    }
    
    func getPoolTasks(req: Request) async throws -> [PoolTask] {
        let id = try req.parameters.require("id", as: Int.self)
        
        async let waterStatus = WaterStatus.query(on: req.db)
            .filter(\.$pool.$id == id)
            .first()
        async let poolStatus = PoolStatus.query(on: req.db)
            .filter(\.$pool.$id == id)
            .first()
        
        let (waterStatusResult, poolStatusResult) = try await (waterStatus, poolStatus)

        guard let waterStatusResult, let poolStatusResult else {
            throw Abort(.notFound)
        }
        
        let poolTasks = PoolTasksManager.tasks(
            waterStatus: waterStatusResult,
            poolStatus: poolStatusResult
        )
        
        return poolTasks
    }
}
