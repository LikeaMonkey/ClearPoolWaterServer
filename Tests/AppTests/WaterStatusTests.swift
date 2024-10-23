//
//  WaterStatusTests.swift
//  ClearPoolWaterServer
//
//  Created by Stanimir Hristov on 22.10.24.
//

import XCTVapor
@testable import App

final class WaterStatusTests: XCTestCase {
    let waterStatusURI = "/api/waterStatus/"
    var app: Application!
    
    override func setUp() async throws {
        app = try await Application.testable()
    }
    
    override func tearDown() async throws {
        try await self.app.asyncShutdown()
        self.app = nil
    }
    
    func testWaterStatusCanBeRetrievedFromAPI() async throws {
        let waterStatus = try await WaterStatus.create(on: app.db)
        
        try await app.test(.GET, waterStatusURI, afterResponse: { response async throws in
            XCTAssertEqual(response.status, .ok)
            let waterStatuses = try response.content.decode([WaterStatus].self)
              
            XCTAssertEqual(waterStatuses.count, 1)
            XCTAssertEqual(waterStatuses[0].id, waterStatus.id)
            XCTAssertEqual(waterStatuses[0].ph, waterStatus.ph)
            XCTAssertEqual(waterStatuses[0].chlorine, waterStatus.chlorine)
            XCTAssertEqual(waterStatuses[0].alkalinity, waterStatus.alkalinity)
            XCTAssertEqual(waterStatuses[0].temperature, waterStatus.temperature)
        })
    }
    
    func testWaterStatusCanBeSavedWithAPI() async throws {
        let pool = try await Pool.create(on: app.db)
        let waterStatus = WaterStatus.Create(
            ph: 7.2,
            chlorine: 0.8,
            alkalinity: 90,
            temperature: 28,
            pool: try pool.requireID()
        )
        
        try await app.test(.POST, waterStatusURI, beforeRequest: { req async throws in
            try req.content.encode(waterStatus)
        }, afterResponse: { response async throws in
            XCTAssertEqual(response.status, .ok)
            let receivedWaterStatus = try response.content.decode(WaterStatus.self)
                          
            XCTAssertNotNil(receivedWaterStatus.id)
            XCTAssertEqual(receivedWaterStatus.ph, waterStatus.ph)
            XCTAssertEqual(receivedWaterStatus.chlorine, waterStatus.chlorine)
            XCTAssertEqual(receivedWaterStatus.alkalinity, waterStatus.alkalinity)
            XCTAssertEqual(receivedWaterStatus.temperature, waterStatus.temperature)
            
            try await app.test(.GET, waterStatusURI, afterResponse: { response async throws in
                XCTAssertEqual(response.status, .ok)
                let waterStatuses = try response.content.decode([WaterStatus].self)
                  
                XCTAssertEqual(waterStatuses.count, 1)
                XCTAssertEqual(waterStatuses[0].id, receivedWaterStatus.id)
                XCTAssertEqual(waterStatuses[0].ph, receivedWaterStatus.ph)
                XCTAssertEqual(waterStatuses[0].chlorine, receivedWaterStatus.chlorine)
                XCTAssertEqual(waterStatuses[0].alkalinity, receivedWaterStatus.alkalinity)
                XCTAssertEqual(waterStatuses[0].temperature, receivedWaterStatus.temperature)
            })
        })
    }
    
    func testGettingASingleWaterStatusFromTheAPI() async throws {
        let waterStatus = try await WaterStatus.create(on: app.db)

        try await app.test(.GET, "\(waterStatusURI)\(waterStatus.id!)", afterResponse: { response async throws in
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
        let waterStatusId = 1

        try await app.test(.GET, "\(waterStatusURI)\(waterStatusId)", afterResponse: { response async throws in
            XCTAssertEqual(response.status, .notFound)
        })
    }
    
    func testUpdatingASingleWaterStatusFromTheAPI() async throws {
        let waterStatus = try await WaterStatus.create(on: app.db)
        let updatedWaterStatus = WaterStatus.Create(
            ph: 7.5,
            chlorine: 1.3,
            alkalinity: 100,
            temperature: 30,
            pool: waterStatus.$pool.id
        )
        
        try await app.test(.PUT, "\(waterStatusURI)\(waterStatus.id!)", beforeRequest: { req async throws in
            try req.content.encode(updatedWaterStatus)
        }, afterResponse: { response async throws in
            XCTAssertEqual(response.status, .ok)
            let receivedWaterStatus = try response.content.decode(WaterStatus.self)
                                      
            XCTAssertEqual(receivedWaterStatus.id, waterStatus.id)
            XCTAssertEqual(receivedWaterStatus.ph, updatedWaterStatus.ph)
            XCTAssertEqual(receivedWaterStatus.chlorine, updatedWaterStatus.chlorine)
            XCTAssertEqual(receivedWaterStatus.alkalinity, updatedWaterStatus.alkalinity)
            XCTAssertEqual(receivedWaterStatus.temperature, updatedWaterStatus.temperature)
        })
    }
    
    func testUpdatingANonExistentWaterStatusFromTheAPI() async throws {
        let waterStatusId = 1
        
        try await app.test(.PUT, "\(waterStatusURI)\(waterStatusId)", afterResponse: { response async throws in
            XCTAssertEqual(response.status, .notFound)
        })
    }
    
    func testUpdatingWaterStatusWithInvalidPHFromTheAPI() async throws {
        let waterStatus = try await WaterStatus.create(on: app.db)
        let updatedWaterStatus = WaterStatus.Create(
            ph: 20,
            chlorine: 0.8,
            alkalinity: 90,
            temperature: 28,
            pool: waterStatus.$pool.id
        )
        
        try await app.test(.PUT, "\(waterStatusURI)\(waterStatus.id!)", beforeRequest: { req async throws in
            try req.content.encode(updatedWaterStatus)
        }, afterResponse: { response async throws in
            XCTAssertEqual(response.status, .badRequest)
        })
    }
    
    func testUpdatingWaterStatusWithInvalidChlorineFromTheAPI() async throws {
        let waterStatus = try await WaterStatus.create(on: app.db)
        let updatedWaterStatus = WaterStatus.Create(
            ph: 7.2,
            chlorine: 11,
            alkalinity: 90,
            temperature: 28,
            pool: waterStatus.$pool.id
        )
        
        try await app.test(.PUT, "\(waterStatusURI)\(waterStatus.id!)", beforeRequest: { req async throws in
            try req.content.encode(updatedWaterStatus)
        }, afterResponse: { response async throws in
            XCTAssertEqual(response.status, .badRequest)
        })
    }
    
    func testUpdatingWaterStatusWithInvalidAlkalinityFromTheAPI() async throws {
        let waterStatus = try await WaterStatus.create(on: app.db)
        let updatedWaterStatus = WaterStatus.Create(
            ph: 7.2,
            chlorine: 0.8,
            alkalinity: 301,
            temperature: 28,
            pool: waterStatus.$pool.id
        )
        
        try await app.test(.PUT, "\(waterStatusURI)\(waterStatus.id!)", beforeRequest: { req async throws in
            try req.content.encode(updatedWaterStatus)
        }, afterResponse: { response async throws in
            XCTAssertEqual(response.status, .badRequest)
        })
    }
    
    func testUpdatingWaterStatusWithInvalidTemperatureFromTheAPI() async throws {
        let waterStatus = try await WaterStatus.create(on: app.db)
        let updatedWaterStatus = WaterStatus.Create(
            ph: 7.2,
            chlorine: 0.8,
            alkalinity: 80,
            temperature: 101,
            pool: waterStatus.$pool.id
        )
        
        try await app.test(.PUT, "\(waterStatusURI)\(waterStatus.id!)", beforeRequest: { req async throws in
            try req.content.encode(updatedWaterStatus)
        }, afterResponse: { response async throws in
            XCTAssertEqual(response.status, .badRequest)
        })
    }
    
    func testDeletingASingleWaterStatusFromTheAPI() async throws {
        let waterStatus = try await WaterStatus.create(on: app.db)
        
        try await app.test(.DELETE, "\(waterStatusURI)\(waterStatus.id!)", afterResponse: { response async throws in
            XCTAssertEqual(response.status, .ok)
        })
    }
    
    func testDeletingANonExistentWaterStatusFromTheAPI() async throws {
        let waterStatusId = 1
        
        try await app.test(.DELETE, "\(waterStatusURI)\(waterStatusId)", afterResponse: { response async throws in
            XCTAssertEqual(response.status, .notFound)
        })
    }
    
    func testGettingWaterStatusForPoolFromTheAPI() async throws {
        let waterStatus = try await WaterStatus.create(on: app.db)
        let poolId = waterStatus.$pool.id
        
        try await app.test(.GET, "\(waterStatusURI)pool/\(poolId)", afterResponse: { response async throws in
            XCTAssertEqual(response.status, .ok)
            let receivedWaterStatus = try response.content.decode(WaterStatus.self)
                          
            XCTAssertEqual(receivedWaterStatus.id, waterStatus.id)
            XCTAssertEqual(receivedWaterStatus.ph, waterStatus.ph)
            XCTAssertEqual(receivedWaterStatus.chlorine, waterStatus.chlorine)
            XCTAssertEqual(receivedWaterStatus.alkalinity, waterStatus.alkalinity)
            XCTAssertEqual(receivedWaterStatus.temperature, waterStatus.temperature)
        })
    }
    
    func testGettingNonExistentWaterStatusForPoolFromTheAPI() async throws {
        let poolId = 1
        
        try await app.test(.GET, "\(waterStatusURI)pool/\(poolId)", afterResponse: { response async throws in
            XCTAssertEqual(response.status, .notFound)
        })
    }
}
