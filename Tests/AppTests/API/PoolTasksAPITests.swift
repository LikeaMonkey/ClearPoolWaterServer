//
//  PoolTasksAPITests.swift
//  ClearPoolWaterServer
//
//  Created by Stanimir Hristov on 24.10.24.
//

import XCTVapor
@testable import App

final class PoolTasksAPITests: XCTestCase {
    let poolTasksURI = "/api/poolTasks/"
    var app: Application!
    
    override func setUp() async throws {
        app = try await Application.testable()
    }
    
    override func tearDown() async throws {
        try await self.app.asyncShutdown()
        self.app = nil
    }
    
    func testGettingTasksForNonExistentPool() async throws {
        let token = try await SessionToken.create(on: app)
        let poolId = 1

        let headers = APIUtils.jwtBearerHeaders(with: token)
        try await app.test(.GET, "\(poolTasksURI)\(poolId)", headers: headers, afterResponse: { response async throws in
            XCTAssertEqual(response.status, .notFound)
        })
    }
    
    func testGettingTasksForNoWaterStatus() async throws {
        let (pool, token) = try await Pool.create(on: app)

        let headers = APIUtils.jwtBearerHeaders(with: token)
        try await app.test(.GET, "\(poolTasksURI)\(pool.id!)", headers: headers, afterResponse: { response async throws in
            XCTAssertEqual(response.status, .notFound)
        })
    }
    
    func testGettingTasksForNoPoolStatus() async throws {
        let (waterStatus, token) = try await WaterStatus.create(on: app)
        let poolId = waterStatus.$pool.id

        let headers = APIUtils.jwtBearerHeaders(with: token)
        try await app.test(.GET, "\(poolTasksURI)\(poolId)", headers: headers, afterResponse: { response async throws in
            XCTAssertEqual(response.status, .notFound)
        })
    }
    
    func testGettingPoolTasks() async throws {
        let (pool, token) = try await Pool.create(on: app)
        _ = try await WaterStatus.create(pool: pool, on: app.db)
        _ = try await PoolStatus.create(pool: pool, on: app.db)

        let headers = APIUtils.jwtBearerHeaders(with: token)
        try await app.test(.GET, "\(poolTasksURI)\(pool.id!)", headers: headers, afterResponse: { response async throws in
            XCTAssertEqual(response.status, .ok)
            let tasks = try response.content.decode([PoolTask].self)
              
            XCTAssertEqual(tasks.count, 8)
        })
    }
    
    func testUnauthorizedCall() async throws {
        let poolId = 1
        
        try await app.test(.GET, "\(poolTasksURI)\(poolId))", afterResponse: { response async throws in
            XCTAssertEqual(response.status, .unauthorized)
        })
    }
}
