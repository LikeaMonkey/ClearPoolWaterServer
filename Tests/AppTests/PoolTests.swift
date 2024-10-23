//
//  PoolTests.swift
//  ClearPoolWaterServer
//
//  Created by Stanimir Hristov on 22.10.24.
//

import XCTVapor
@testable import App

final class PoolTests: XCTestCase {
    let poolsURI = "/api/pools/"
    var app: Application!
    
    override func setUp() async throws {
        app = try await Application.testable()
    }
    
    override func tearDown() async throws {
        try await self.app.asyncShutdown()
        self.app = nil
    }
    
    func testPoolCanBeRetrievedFromAPI() async throws {
        let pool = try await Pool.create(on: app.db)
        
        try await app.test(.GET, poolsURI, afterResponse: { response async throws in
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
        let user = try await User.create(on: app.db)
        let pool = Pool.Create(
            name: "Test Pool",
            waterLevel: 0.8,
            waterCapacity: 5,
            filterType: .sand,
            user: try user.requireID()
        )
        
        try await app.test(.POST, poolsURI, beforeRequest: { req async throws in
            try req.content.encode(pool)
        }, afterResponse: { response async throws in
            XCTAssertEqual(response.status, .ok)
            let receivedPool = try response.content.decode(Pool.self)
            
            XCTAssertEqual(receivedPool.name, pool.name)
            XCTAssertEqual(receivedPool.waterLevel, pool.waterLevel)
            XCTAssertEqual(receivedPool.waterCapacity, pool.waterCapacity)
            XCTAssertEqual(receivedPool.filterType, pool.filterType)
            XCTAssertNotNil(receivedPool.id)
            
            try await app.test(.GET, poolsURI, afterResponse: { response async throws in
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
        let pool = try await Pool.create(on: app.db)

        try await app.test(.GET, "\(poolsURI)\(pool.id!)", afterResponse: { response async throws in
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
        let poolId = 1

        try await app.test(.GET, "\(poolsURI)\(poolId)", afterResponse: { response async throws in
            XCTAssertEqual(response.status, .notFound)
        })
    }
    
    func testUpdatingASinglePoolFromTheAPI() async throws {
        let pool = try await Pool.create(on: app.db)
        let updatedPool = Pool.Create(
            name: "Updated Pool",
            waterLevel: 0.9,
            waterCapacity: 10,
            filterType: .cartridge,
            user: try pool.requireID()
        )
        
        try await app.test(.PUT, "\(poolsURI)\(pool.id!)", beforeRequest: { req async throws in
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
        let poolId = 1
        
        try await app.test(.PUT, "\(poolsURI)\(poolId)", afterResponse: { response async throws in
            XCTAssertEqual(response.status, .notFound)
        })
    }
    
    func testUpdatingASinglePoolWithInvalidNameFromTheAPI() async throws {
        let pool = try await Pool.create(on: app.db)
        let updatedPool = Pool.Create(
            name: "Too Long Nameeeeeeeeeeeeeeeeeee",
            waterLevel: 0.8,
            waterCapacity: 5,
            filterType: .sand,
            user: try pool.requireID()
        )
        
        try await app.test(.PUT, "\(poolsURI)\(pool.id!)", beforeRequest: { req async throws in
            try req.content.encode(updatedPool)
        }, afterResponse: { response async throws in
            XCTAssertEqual(response.status, .badRequest)
        })
    }
    
    func testUpdatingASinglePoolWithInvalidWaterLevelFromTheAPI() async throws {
        let pool = try await Pool.create(on: app.db)
        let updatedPool = Pool.Create(
            name: "Test Pool",
            waterLevel: 1.1,
            waterCapacity: 5,
            filterType: .sand,
            user: try pool.requireID()
        )
        
        try await app.test(.PUT, "\(poolsURI)\(pool.id!)", beforeRequest: { req async throws in
            try req.content.encode(updatedPool)
        }, afterResponse: { response async throws in
            XCTAssertEqual(response.status, .badRequest)
        })
    }
    
    func testUpdatingASinglePoolWithInvalidWaterCapacityFromTheAPI() async throws {
        let pool = try await Pool.create(on: app.db)
        let updatedPool = Pool.Create(
            name: "Test Pool",
            waterLevel: 1.1,
            waterCapacity: -1,
            filterType: .sand,
            user: try pool.requireID()
        )
        
        try await app.test(.PUT, "\(poolsURI)\(pool.id!)", beforeRequest: { req async throws in
            try req.content.encode(updatedPool)
        }, afterResponse: { response async throws in
            XCTAssertEqual(response.status, .badRequest)
        })
    }
    
    func testDeletingASinglePoolFromTheAPI() async throws {
        let pool = try await Pool.create(on: app.db)
        
        try await app.test(.DELETE, "\(poolsURI)\(pool.id!)", afterResponse: { response async throws in
            XCTAssertEqual(response.status, .ok)
        })
    }
    
    func testDeletingANonExistentPoolFromTheAPI() async throws {
        let poolId = 1
        
        try await app.test(.DELETE, "\(poolsURI)\(poolId)", afterResponse: { response async throws in
            XCTAssertEqual(response.status, .notFound)
        })
    }
    
    func testGettingUserPoolsFromTheAPI() async throws {
        let pool = try await Pool.create(on: app.db)
        let userId = pool.$user.id
        
        try await app.test(.GET, "\(poolsURI)user/\(userId)", afterResponse: { response async throws in
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
    
    func testGettingNonExistentUserPoolsFromTheAPI() async throws {
        let userId = 1
        
        try await app.test(.GET, "\(poolsURI)user/\(userId)", afterResponse: { response async throws in
            XCTAssertEqual(response.status, .ok)
            let pools = try response.content.decode([Pool].self)
            
            XCTAssertTrue(pools.isEmpty)
        })
    }
}
