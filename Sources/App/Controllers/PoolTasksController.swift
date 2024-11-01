//
//  PoolTasksController.swift
//  ClearPoolWaterServer
//
//  Created by Stanimir Hristov on 23.10.24.
//

import Vapor
import Fluent

final class PoolTasksController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let secure = routes.grouped(
            SessionToken.authenticator(),
            SessionToken.guardMiddleware()
        )
        
        secure.group("api", "poolTasks", ":id") { pool in
            pool.get(use: getPoolTasks)
        }
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
