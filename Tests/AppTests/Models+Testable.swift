//
//  Models+Testable.swift
//  ClearPoolWaterServer
//
//  Created by Stanimir Hristov on 22.10.24.
//

import Vapor
import Fluent
import JWT
@testable import App

extension User {
    static func create(
        email: String = "stanga@stanga.com",
        password: String = "12345678",
        role: User.Role = .user,
        on database: Database
    ) async throws -> User {
        let user = try User(
            email: email,
            passwordHash: Bcrypt.hash(password),
            role: role
        )
        try await user.save(on: database)
        
        return user
    }
    
    static func create(
        email: String = "stanga@stanga.com",
        password: String = "12345678",
        role: User.Role = .user,
        on app: Application
    ) async throws -> (user: User, token: String) {
        let user = try await create(email: email, password: password, role: role, on: app.db)

        let token = try await SessionToken.create(user: user, on: app)

        return (user, token)
    }
}

extension SessionToken {
    static func create(user: User? = nil, on app: Application) async throws -> String {
        var user = user
        if user == nil {
            user = try await User.create(on: app.db)
        }
        
        let payload = try SessionToken(with: user!)

        return try await app.jwt.keys.sign(payload)
    }
}

extension Pool {
    static func create(
        name: String = "Test Pool",
        waterLevel: Double = 0.8,
        waterCapacity: Double = 5,
        filterType: FilterType = .sand,
        user: User? = nil,
        on database: Database
    ) async throws -> Pool {
        var poolUser = user
        if poolUser == nil {
            poolUser = try await User.create(on: database)
        }
        
        let pool = Pool(
            name: name,
            waterLevel: waterLevel,
            waterCapacity: waterCapacity,
            filterType: filterType,
            userID: poolUser!.id!
        )
        try await pool.save(on: database)
        
        return pool
    }
    
    static func create(
        name: String = "Test Pool",
        waterLevel: Double = 0.8,
        waterCapacity: Double = 5,
        filterType: FilterType = .sand,
        on app: Application
    ) async throws -> (pool: Pool, token: String) {
        let (user, token) = try await User.create(on: app)
        
        let pool = Pool(
            name: name,
            waterLevel: waterLevel,
            waterCapacity: waterCapacity,
            filterType: filterType,
            userID: user.id!
        )
        try await pool.save(on: app.db)
        
        return (pool, token)
    }
}

extension PoolStatus {
    static func create(
        skim: Bool = true,
        vacuum: Bool = false,
        brush: Bool = false,
        emptyBaskets: Bool = false,
        testWater: Bool = false,
        cleanFilter: Bool = false,
        runPump: Bool = false,
        inspect: Bool = false,
        pool: Pool? = nil,
        on database: Database
    ) async throws -> PoolStatus {
        var pool = pool
        if pool == nil {
            pool = try await Pool.create(on: database)
        }
        
        let poolStatus = PoolStatus(
            skimDate: skim ? .now : nil,
            vacuumDate: vacuum ? .now : nil,
            brushDate: brush ? .now : nil,
            emptyBasketsDate: emptyBaskets ? .now : nil,
            testWaterDate: testWater ? .now : nil,
            cleanFilterDate: cleanFilter ? .now : nil,
            runPumpDate: runPump ? .now : nil,
            inspectDate: inspect ? .now : nil,
            poolID: pool!.id!
        )
        try await poolStatus.save(on: database)
        
        return poolStatus
    }
    
    static func create(
        skim: Bool = true,
        vacuum: Bool = false,
        brush: Bool = false,
        emptyBaskets: Bool = false,
        testWater: Bool = false,
        cleanFilter: Bool = false,
        runPump: Bool = false,
        inspect: Bool = false,
        on app: Application
    ) async throws -> (poolStatus: PoolStatus, token: String) {
        let (pool, token) = try await Pool.create(on: app)
        
        let poolStatus = PoolStatus(
            skimDate: skim ? .now : nil,
            vacuumDate: vacuum ? .now : nil,
            brushDate: brush ? .now : nil,
            emptyBasketsDate: emptyBaskets ? .now : nil,
            testWaterDate: testWater ? .now : nil,
            cleanFilterDate: cleanFilter ? .now : nil,
            runPumpDate: runPump ? .now : nil,
            inspectDate: inspect ? .now : nil,
            poolID: pool.id!
        )
        try await poolStatus.save(on: app.db)
        
        return (poolStatus, token)
    }
}

extension WaterStatus {
    static func create(
        ph: Double = 7.2,
        chlorine: Double = 0.8,
        alkalinity: Double = 90,
        temperature: Double = 28,
        pool: Pool? = nil,
        on database: Database
    ) async throws -> WaterStatus {
        var waterStatusPool = pool
        if waterStatusPool == nil {
            waterStatusPool = try await Pool.create(on: database)
        }
        
        let waterStatus = WaterStatus(
            ph: ph,
            chlorine: chlorine,
            alkalinity: alkalinity,
            temperature: temperature,
            poolID: waterStatusPool!.id!
        )
        try await waterStatus.save(on: database)
        
        return waterStatus
    }
    
    static func create(
        ph: Double = 7.2,
        chlorine: Double = 0.8,
        alkalinity: Double = 90,
        temperature: Double = 28,
        on app: Application
    ) async throws -> (waterStatus: WaterStatus, token: String) {
        let (pool, token) = try await Pool.create(on: app)
        
        let waterStatus = WaterStatus(
            ph: ph,
            chlorine: chlorine,
            alkalinity: alkalinity,
            temperature: temperature,
            poolID: pool.id!
        )
        try await waterStatus.save(on: app.db)
        
        return (waterStatus, token)
    }
}
