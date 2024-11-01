//
//  PoolStatusAPITests.swift
//  ClearPoolWaterServer
//
//  Created by Stanimir Hristov on 22.10.24.
//

import XCTVapor
@testable import App

final class PoolStatusAPITests: XCTestCase {
    let poolStatusURI = "/api/poolStatus/"
    var app: Application!
    
    override func setUp() async throws {
        app = try await Application.testable()
    }
    
    override func tearDown() async throws {
        try await self.app.asyncShutdown()
        self.app = nil
    }
    
    func testPoolStatusCanBeRetrievedFromAPI() async throws {
        let (poolStatus, token) = try await PoolStatus.create(on: app)
        
        let headers = APIUtils.jwtBearerHeaders(with: token)
        try await app.test(.GET, poolStatusURI, headers: headers, afterResponse: { response async throws in
            XCTAssertEqual(response.status, .ok)
            let poolStatuses = try response.content.decode([PoolStatus].self)
              
            XCTAssertEqual(poolStatuses.count, 1)
            XCTAssertEqual(poolStatuses[0].id, poolStatus.id)
            XCTAssertTrue(DateUtils.isSameDay(poolStatuses[0].skimDate!, poolStatus.skimDate!))
            XCTAssertEqual(poolStatuses[0].vacuumDate, poolStatus.vacuumDate)
            XCTAssertEqual(poolStatuses[0].brushDate, poolStatus.brushDate)
            XCTAssertEqual(poolStatuses[0].emptyBasketsDate, poolStatus.emptyBasketsDate)
            XCTAssertEqual(poolStatuses[0].testWaterDate, poolStatus.testWaterDate)
            XCTAssertEqual(poolStatuses[0].cleanFilterDate, poolStatus.cleanFilterDate)
            XCTAssertEqual(poolStatuses[0].runPumpDate, poolStatus.runPumpDate)
            XCTAssertEqual(poolStatuses[0].inspectDate, poolStatus.inspectDate)
        })
    }
    
    func testPoolStatusCanBeSavedWithAPI() async throws {
        let (pool, token) = try await Pool.create(on: app)
        let poolStatus = PoolStatus.Create(
            skim: true,
            pool: try pool.requireID()
        )
        
        let headers = APIUtils.jwtBearerHeaders(with: token)
        try await app.test(.POST, poolStatusURI, headers: headers, beforeRequest: { req async throws in
            try req.content.encode(poolStatus)
        }, afterResponse: { response async throws in
            XCTAssertEqual(response.status, .ok)
            let receivedPoolStatus = try response.content.decode(PoolStatus.self)
            
            XCTAssertNotNil(receivedPoolStatus.id)
            
            XCTAssertNotNil(receivedPoolStatus.skimDate)
            XCTAssertTrue(DateUtils.isSameDay(receivedPoolStatus.skimDate!, .now))
            
            XCTAssertNil(receivedPoolStatus.vacuumDate)
            XCTAssertNil(receivedPoolStatus.brushDate)
            XCTAssertNil(receivedPoolStatus.emptyBasketsDate)
            XCTAssertNil(receivedPoolStatus.testWaterDate)
            XCTAssertNil(receivedPoolStatus.cleanFilterDate)
            XCTAssertNil(receivedPoolStatus.runPumpDate)
            XCTAssertNil(receivedPoolStatus.inspectDate)
            
            try await app.test(.GET, poolStatusURI, headers: headers, afterResponse: { response async throws in
                XCTAssertEqual(response.status, .ok)
                let poolStatuses = try response.content.decode([PoolStatus].self)
                  
                XCTAssertEqual(poolStatuses.count, 1)
                XCTAssertEqual(poolStatuses[0].id, receivedPoolStatus.id)
                XCTAssertTrue(DateUtils.isSameDay(poolStatuses[0].skimDate!, receivedPoolStatus.skimDate!))
                XCTAssertEqual(poolStatuses[0].vacuumDate, receivedPoolStatus.vacuumDate)
                XCTAssertEqual(poolStatuses[0].brushDate, receivedPoolStatus.brushDate)
                XCTAssertEqual(poolStatuses[0].emptyBasketsDate, receivedPoolStatus.emptyBasketsDate)
                XCTAssertEqual(poolStatuses[0].testWaterDate, receivedPoolStatus.testWaterDate)
                XCTAssertEqual(poolStatuses[0].cleanFilterDate, receivedPoolStatus.cleanFilterDate)
                XCTAssertEqual(poolStatuses[0].runPumpDate, receivedPoolStatus.runPumpDate)
                XCTAssertEqual(poolStatuses[0].inspectDate, receivedPoolStatus.inspectDate)
            })
        })
    }
    
    func testGettingASinglePoolStatusFromTheAPI() async throws {
        let (poolStatus, token) = try await PoolStatus.create(on: app)

        let headers = APIUtils.jwtBearerHeaders(with: token)
        try await app.test(.GET, "\(poolStatusURI)\(poolStatus.id!)", headers: headers, afterResponse: { response async throws in
            XCTAssertEqual(response.status, .ok)
            let receivedPoolStatus = try response.content.decode(PoolStatus.self)
            
            XCTAssertEqual(receivedPoolStatus.id, poolStatus.id)
            
            XCTAssertNotNil(receivedPoolStatus.skimDate)
            XCTAssertTrue(DateUtils.isSameDay(receivedPoolStatus.skimDate!, poolStatus.skimDate!))
            
            XCTAssertNil(receivedPoolStatus.vacuumDate)
            XCTAssertNil(receivedPoolStatus.brushDate)
            XCTAssertNil(receivedPoolStatus.emptyBasketsDate)
            XCTAssertNil(receivedPoolStatus.testWaterDate)
            XCTAssertNil(receivedPoolStatus.cleanFilterDate)
            XCTAssertNil(receivedPoolStatus.runPumpDate)
            XCTAssertNil(receivedPoolStatus.inspectDate)
        })
    }
    
    func testGettingNonExistentSinglePoolStatusFromTheAPI() async throws {
        let token = try await SessionToken.create(on: app)
        let poolStatusId = 1

        let headers = APIUtils.jwtBearerHeaders(with: token)
        try await app.test(.GET, "\(poolStatusURI)\(poolStatusId)", headers: headers, afterResponse: { response async throws in
            XCTAssertEqual(response.status, .notFound)
        })
    }
    
    func testUpdatingASinglePoolStatusFromTheAPI() async throws {
        let (poolStatus, token) = try await PoolStatus.create(on: app)
        let updatedPoolStatus = PoolStatus.Create(
            skim: true,
            vacuum: true,
            brush: true,
            emptyBaskets: true,
            testWater: true,
            cleanFilter: true,
            runPump: true,
            inspect: true,
            pool: poolStatus.$pool.id
        )
        
        let headers = APIUtils.jwtBearerHeaders(with: token)
        try await app.test(.PUT, "\(poolStatusURI)\(poolStatus.id!)", headers: headers, beforeRequest: { req async throws in
            try req.content.encode(updatedPoolStatus)
        }, afterResponse: { response async throws in
            XCTAssertEqual(response.status, .ok)
            let receivedPoolStatus = try response.content.decode(PoolStatus.self)
            
            XCTAssertEqual(receivedPoolStatus.id, poolStatus.id)
            
            XCTAssertNotNil(receivedPoolStatus.skimDate)
            XCTAssertTrue(DateUtils.isSameDay(receivedPoolStatus.skimDate!, .now))
            XCTAssertNotNil(receivedPoolStatus.vacuumDate)
            XCTAssertTrue(DateUtils.isSameDay(receivedPoolStatus.vacuumDate!, .now))
            XCTAssertNotNil(receivedPoolStatus.brushDate)
            XCTAssertTrue(DateUtils.isSameDay(receivedPoolStatus.brushDate!, .now))
            XCTAssertNotNil(receivedPoolStatus.emptyBasketsDate)
            XCTAssertTrue(DateUtils.isSameDay(receivedPoolStatus.emptyBasketsDate!, .now))
            XCTAssertNotNil(receivedPoolStatus.testWaterDate)
            XCTAssertTrue(DateUtils.isSameDay(receivedPoolStatus.testWaterDate!, .now))
            XCTAssertNotNil(receivedPoolStatus.cleanFilterDate)
            XCTAssertTrue(DateUtils.isSameDay(receivedPoolStatus.cleanFilterDate!, .now))
            XCTAssertNotNil(receivedPoolStatus.runPumpDate)
            XCTAssertTrue(DateUtils.isSameDay(receivedPoolStatus.runPumpDate!, .now))
            XCTAssertNotNil(receivedPoolStatus.inspectDate)
            XCTAssertTrue(DateUtils.isSameDay(receivedPoolStatus.inspectDate!, .now))
        })
    }
    
    func testUpdatingANonExistentPoolStatusFromTheAPI() async throws {
        let token = try await SessionToken.create(on: app)
        let poolStatusId = 1
        
        let headers = APIUtils.jwtBearerHeaders(with: token)
        try await app.test(.PUT, "\(poolStatusURI)\(poolStatusId)", headers: headers, afterResponse: { response async throws in
            XCTAssertEqual(response.status, .notFound)
        })
    }
    
    func testDeletingASinglePoolStatusFromTheAPI() async throws {
        let (poolStatus, token) = try await PoolStatus.create(on: app)
        
        let headers = APIUtils.jwtBearerHeaders(with: token)
        try await app.test(.DELETE, "\(poolStatusURI)\(poolStatus.id!)", headers: headers, afterResponse: { response async throws in
            XCTAssertEqual(response.status, .ok)
        })
    }
    
    func testDeletingANonExistentPoolStatusFromTheAPI() async throws {
        let token = try await SessionToken.create(on: app)
        let poolStatusId = 1
        
        let headers = APIUtils.jwtBearerHeaders(with: token)
        try await app.test(.DELETE, "\(poolStatusURI)\(poolStatusId)", headers: headers, afterResponse: { response async throws in
            XCTAssertEqual(response.status, .notFound)
        })
    }
    
    func testGettingPoolStatusForPoolFromTheAPI() async throws {
        let (poolStatus, token) = try await PoolStatus.create(on: app)
        let poolId = poolStatus.$pool.id
        
        let headers = APIUtils.jwtBearerHeaders(with: token)
        try await app.test(.GET, "\(poolStatusURI)pool/\(poolId)", headers: headers, afterResponse: { response async throws in
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
    
    func testGettingNonExistentPoolStatusForPoolFromTheAPI() async throws {
        let token = try await SessionToken.create(on: app)
        let poolId = 1
        
        let headers = APIUtils.jwtBearerHeaders(with: token)
        try await app.test(.GET, "\(poolStatusURI)pool/\(poolId)", headers: headers, afterResponse: { response async throws in
            XCTAssertEqual(response.status, .notFound)
        })
    }
    
    func testUnauthorizedCall() async throws {
        try await app.test(.GET, poolStatusURI, afterResponse: { response async throws in
            XCTAssertEqual(response.status, .unauthorized)
        })
    }
}
