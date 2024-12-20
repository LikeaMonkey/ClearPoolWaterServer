//
//  PoolAPITests.swift
//  ClearPoolWaterServer
//
//  Created by Stanimir Hristov on 22.10.24.
//

import XCTVapor
@testable import App

final class PoolAPITests: XCTestCase {
    let poolsURI = "/api/pools/"
    
    func poolsURI(id: Int) -> String { poolsURI + "\(id)/" }
    
    func poolStatusURI(id: Int) -> String { poolsURI(id: id) + "poolStatus" }
    func waterStatusURI(id: Int) -> String { poolsURI(id: id) + "waterStatus" }
    func tasksURI(id: Int) -> String { poolsURI(id: id) + "tasks" }

    var app: Application!
    
    override func setUp() async throws {
        app = try await Application.testable()
    }
    
    override func tearDown() async throws {
        try await self.app.asyncShutdown()
        self.app = nil
    }
    
    func testPoolCanBeRetrievedFromAPI() async throws {
        let (pool, token) = try await Pool.create(on: app)
        
        let headers = APIUtils.jwtBearerHeaders(with: token)
        try await app.test(.GET, poolsURI, headers: headers, afterResponse: { response async throws in
            XCTAssertEqual(response.status, .ok)
            let pools = try response.content.decode([Pool].self)
              
            XCTAssertEqual(pools.count, 1)
            XCTAssertEqual(pools[0].id, pool.id)
            XCTAssertEqual(pools[0].name, pool.name)
            XCTAssertEqual(pools[0].waterLevel, pool.waterLevel)
            XCTAssertEqual(pools[0].waterCapacity, pool.waterCapacity)
            XCTAssertEqual(pools[0].filterType, pool.filterType)
        })
    }
    
    func testPoolCanBeSavedWithAPI() async throws {
        let token = try await SessionToken.create(on: app)
        let pool = Pool.Create(
            name: "Test Pool",
            waterLevel: 0.8,
            waterCapacity: 5,
            filterType: .sand
        )
        
        let headers = APIUtils.jwtBearerHeaders(with: token)
        try await app.test(.POST, poolsURI, headers: headers, beforeRequest: { req async throws in
            try req.content.encode(pool)
        }, afterResponse: { response async throws in
            XCTAssertEqual(response.status, .ok)
            let receivedPool = try response.content.decode(Pool.self)
            
            XCTAssertEqual(receivedPool.name, pool.name)
            XCTAssertEqual(receivedPool.waterLevel, pool.waterLevel)
            XCTAssertEqual(receivedPool.waterCapacity, pool.waterCapacity)
            XCTAssertEqual(receivedPool.filterType, pool.filterType)
            XCTAssertNotNil(receivedPool.id)
            
            try await app.test(.GET, poolsURI, headers: headers, afterResponse: { response async throws in
                XCTAssertEqual(response.status, .ok)
                let pools = try response.content.decode([Pool].self)
                
                XCTAssertEqual(pools.count, 1)
                XCTAssertEqual(pools[0].id, receivedPool.id)
                XCTAssertEqual(pools[0].name, receivedPool.name)
                XCTAssertEqual(pools[0].waterLevel, receivedPool.waterLevel)
                XCTAssertEqual(pools[0].waterCapacity, receivedPool.waterCapacity)
                XCTAssertEqual(pools[0].filterType, receivedPool.filterType)
            })
        })
    }
    
    func testGettingASinglePoolFromTheAPI() async throws {
        let (pool, token) = try await Pool.create(on: app)

        let headers = APIUtils.jwtBearerHeaders(with: token)
        try await app.test(.GET, poolsURI(id: pool.id!), headers: headers, afterResponse: { response async throws in
            XCTAssertEqual(response.status, .ok)
            let receivedPool = try response.content.decode(Pool.self)
            
            XCTAssertEqual(receivedPool.name, pool.name)
            XCTAssertEqual(receivedPool.waterLevel, pool.waterLevel)
            XCTAssertEqual(receivedPool.waterCapacity, pool.waterCapacity)
            XCTAssertEqual(receivedPool.filterType, pool.filterType)
            XCTAssertEqual(receivedPool.id, pool.id)
        })
    }
    
    func testGettingNonExistentSinglePoolFromTheAPI() async throws {
        let token = try await SessionToken.create(on: app)
        let poolId = 1

        let headers = APIUtils.jwtBearerHeaders(with: token)
        try await app.test(.GET, poolsURI(id: poolId), headers: headers, afterResponse: { response async throws in
            XCTAssertEqual(response.status, .notFound)
        })
    }
    
    func testUpdatingASinglePoolFromTheAPI() async throws {
        let (pool, token) = try await Pool.create(on: app)
        let updatedPool = Pool.Create(
            name: "Updated Pool",
            waterLevel: 0.9,
            waterCapacity: 10,
            filterType: .cartridge
        )
        
        let headers = APIUtils.jwtBearerHeaders(with: token)
        try await app.test(.PUT, poolsURI(id: pool.id!), headers: headers, beforeRequest: { req async throws in
            try req.content.encode(updatedPool)
        }, afterResponse: { response async throws in
            XCTAssertEqual(response.status, .ok)
            let receivedPool = try response.content.decode(Pool.self)
            
            XCTAssertEqual(receivedPool.name, updatedPool.name)
            XCTAssertEqual(receivedPool.waterLevel, updatedPool.waterLevel)
            XCTAssertEqual(receivedPool.waterCapacity, updatedPool.waterCapacity)
            XCTAssertEqual(receivedPool.filterType, updatedPool.filterType)
            XCTAssertEqual(receivedPool.id, pool.id!)
        })
    }
    
    func testUpdatingANonExistentPoolFromTheAPI() async throws {
        let token = try await SessionToken.create(on: app)
        let poolId = 1
        
        let headers = APIUtils.jwtBearerHeaders(with: token)
        try await app.test(.PUT, poolsURI(id: poolId), headers: headers, afterResponse: { response async throws in
            XCTAssertEqual(response.status, .notFound)
        })
    }
    
    func testUpdatingASinglePoolWithInvalidNameFromTheAPI() async throws {
        let (pool, token) = try await Pool.create(on: app)
        let updatedPool = Pool.Create(
            name: "Too Long Nameeeeeeeeeeeeeeeeeee",
            waterLevel: 0.8,
            waterCapacity: 5,
            filterType: .sand
        )
        
        let headers = APIUtils.jwtBearerHeaders(with: token)
        try await app.test(.PUT, poolsURI(id: pool.id!), headers: headers, beforeRequest: { req async throws in
            try req.content.encode(updatedPool)
        }, afterResponse: { response async throws in
            XCTAssertEqual(response.status, .badRequest)
        })
    }
    
    func testUpdatingASinglePoolWithInvalidWaterLevelFromTheAPI() async throws {
        let (pool, token) = try await Pool.create(on: app)
        let updatedPool = Pool.Create(
            name: "Test Pool",
            waterLevel: 1.1,
            waterCapacity: 5,
            filterType: .sand
        )

        let headers = APIUtils.jwtBearerHeaders(with: token)
        try await app.test(.PUT, poolsURI(id: pool.id!), headers: headers, beforeRequest: { req async throws in
            try req.content.encode(updatedPool)
        }, afterResponse: { response async throws in
            XCTAssertEqual(response.status, .badRequest)
        })
    }
    
    func testUpdatingASinglePoolWithInvalidWaterCapacityFromTheAPI() async throws {
        let (pool, token) = try await Pool.create(on: app)
        let updatedPool = Pool.Create(
            name: "Test Pool",
            waterLevel: 1.1,
            waterCapacity: -1,
            filterType: .sand
        )
        
        let headers = APIUtils.jwtBearerHeaders(with: token)
        try await app.test(.PUT, poolsURI(id: pool.id!), headers: headers, beforeRequest: { req async throws in
            try req.content.encode(updatedPool)
        }, afterResponse: { response async throws in
            XCTAssertEqual(response.status, .badRequest)
        })
    }
    
    func testDeletingASinglePoolFromTheAPI() async throws {
        let (pool, token) = try await Pool.create(on: app)
        
        let headers = APIUtils.jwtBearerHeaders(with: token)
        try await app.test(.DELETE, poolsURI(id: pool.id!), headers: headers, afterResponse: { response async throws in
            XCTAssertEqual(response.status, .ok)
        })
    }
    
    func testDeletingANonExistentPoolFromTheAPI() async throws {
        let token = try await SessionToken.create(on: app)
        let poolId = 1
        
        let headers = APIUtils.jwtBearerHeaders(with: token)
        try await app.test(.DELETE, poolsURI(id: poolId), headers: headers, afterResponse: { response async throws in
            XCTAssertEqual(response.status, .notFound)
        })
    }
    
    func testGettingUserPoolsFromTheAPI() async throws {
        let (pool, token) = try await Pool.create(on: app)

        let headers = APIUtils.jwtBearerHeaders(with: token)
        try await app.test(.GET, poolsURI, headers: headers) { response async throws in
            XCTAssertEqual(response.status, .ok)
            let pools = try response.content.decode([Pool].self)
            
            XCTAssertEqual(pools.count, 1)
            XCTAssertEqual(pools[0].id, pool.id)
            XCTAssertEqual(pools[0].name, pool.name)
            XCTAssertEqual(pools[0].waterLevel, pool.waterLevel)
            XCTAssertEqual(pools[0].waterCapacity, pool.waterCapacity)
            XCTAssertEqual(pools[0].filterType, pool.filterType)
        }
    }
    
    func testGettingNonExistentUserPoolsFromTheAPI() async throws {
        let token = try await SessionToken.create(on: app)
        
        let headers = APIUtils.jwtBearerHeaders(with: token)
        try await app.test(.GET, poolsURI, headers: headers, afterResponse: { response async throws in
            XCTAssertEqual(response.status, .ok)
            let pools = try response.content.decode([Pool].self)
            
            XCTAssertTrue(pools.isEmpty)
        })
    }
    
    func testUnathorizedRequest() async throws {
        try await app.test(.GET, poolsURI, afterResponse: { response async throws in
            XCTAssertEqual(response.status, .unauthorized)
        })
    }
    
    func testGettingPoolStatusFromTheAPI() async throws {
        let (poolStatus, token) = try await PoolStatus.create(on: app)
        let poolId = poolStatus.$pool.id
        
        let headers = APIUtils.jwtBearerHeaders(with: token)
        try await app.test(.GET, poolStatusURI(id: poolId), headers: headers, afterResponse: { response async throws in
            XCTAssertEqual(response.status, .ok)
            let receivedPoolStatus = try response.content.decode(PoolStatus.self)
            
            XCTAssertEqual(receivedPoolStatus.id, poolStatus.id)
            
            XCTAssertNotNil(receivedPoolStatus.skimDate)
            XCTAssertTrue(DateUtils.isSameDay(receivedPoolStatus.skimDate!, .now))
            
            XCTAssertNil(receivedPoolStatus.vacuumDate)
            XCTAssertNil(receivedPoolStatus.brushDate)
            XCTAssertNil(receivedPoolStatus.emptyBasketsDate)
            XCTAssertNil(receivedPoolStatus.testWaterDate)
            XCTAssertNil(receivedPoolStatus.cleanFilterDate)
            XCTAssertNil(receivedPoolStatus.runPumpDate)
            XCTAssertNil(receivedPoolStatus.inspectDate)
        })
    }
    
    func testGettingNonExistentPoolStatusFromTheAPI() async throws {
        let token = try await SessionToken.create(on: app)
        let poolId = 1
        
        let headers = APIUtils.jwtBearerHeaders(with: token)
        try await app.test(.GET, poolStatusURI(id: poolId), headers: headers, afterResponse: { response async throws in
            XCTAssertEqual(response.status, .notFound)
        })
    }
    
    func testGettingWaterStatusFromTheAPI() async throws {
        let (waterStatus, token) = try await WaterStatus.create(on: app)
        let poolId = waterStatus.$pool.id
        
        let headers = APIUtils.jwtBearerHeaders(with: token)
        try await app.test(.GET, waterStatusURI(id: poolId), headers: headers, afterResponse: { response async throws in
            XCTAssertEqual(response.status, .ok)
            let receivedWaterStatus = try response.content.decode(WaterStatus.self)
                          
            XCTAssertEqual(receivedWaterStatus.id, waterStatus.id)
            XCTAssertEqual(receivedWaterStatus.ph, waterStatus.ph)
            XCTAssertEqual(receivedWaterStatus.chlorine, waterStatus.chlorine)
            XCTAssertEqual(receivedWaterStatus.alkalinity, waterStatus.alkalinity)
            XCTAssertEqual(receivedWaterStatus.temperature, waterStatus.temperature)
        })
    }
    
    func testGettingNonExistentWaterStatusFromTheAPI() async throws {
        let token = try await SessionToken.create(on: app)
        let poolId = 1
        
        let headers = APIUtils.jwtBearerHeaders(with: token)
        try await app.test(.GET, waterStatusURI(id: poolId), headers: headers, afterResponse: { response async throws in
            XCTAssertEqual(response.status, .notFound)
        })
    }
    
    func testGettingTasksForNonExistentPool() async throws {
        let token = try await SessionToken.create(on: app)
        let poolId = 1

        let headers = APIUtils.jwtBearerHeaders(with: token)
        try await app.test(.GET, tasksURI(id: poolId), headers: headers, afterResponse: { response async throws in
            XCTAssertEqual(response.status, .notFound)
        })
    }
    
    func testGettingTasksForNoWaterStatus() async throws {
        let (pool, token) = try await Pool.create(on: app)

        let headers = APIUtils.jwtBearerHeaders(with: token)
        try await app.test(.GET, tasksURI(id: pool.id!), headers: headers, afterResponse: { response async throws in
            XCTAssertEqual(response.status, .notFound)
        })
    }
    
    func testGettingTasksForNoPoolStatus() async throws {
        let (waterStatus, token) = try await WaterStatus.create(on: app)
        let poolId = waterStatus.$pool.id

        let headers = APIUtils.jwtBearerHeaders(with: token)
        try await app.test(.GET, tasksURI(id: poolId), headers: headers, afterResponse: { response async throws in
            XCTAssertEqual(response.status, .notFound)
        })
    }
    
    func testGettingPoolTasks() async throws {
        let (pool, token) = try await Pool.create(on: app)
        _ = try await WaterStatus.create(pool: pool, on: app.db)
        _ = try await PoolStatus.create(pool: pool, on: app.db)

        let headers = APIUtils.jwtBearerHeaders(with: token)
        try await app.test(.GET, tasksURI(id: pool.id!), headers: headers, afterResponse: { response async throws in
            XCTAssertEqual(response.status, .ok)
            let tasks = try response.content.decode([PoolTask].self)
              
            XCTAssertEqual(tasks.count, 8)
        })
    }
    
    func testUnauthorizedCall() async throws {
        let poolId = 1
        
        try await app.test(.GET, tasksURI(id: poolId), afterResponse: { response async throws in
            XCTAssertEqual(response.status, .unauthorized)
        })
    }
}
