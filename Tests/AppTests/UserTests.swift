//
//  UserTests.swift
//  ClearPoolWaterServer
//
//  Created by Stanimir Hristov on 22.10.24.
//

import XCTVapor
@testable import App

final class UserTests: XCTestCase {
    let usersURI = "/api/users/"
    var app: Application!
    
    override func setUp() async throws {
        app = try await Application.testable()
    }
    
    override func tearDown() async throws {
        try await self.app.asyncShutdown()
        self.app = nil
    }
    
    func testUsersCanBeRetrievedFromAPI() async throws {
        let user = try await User.create(on: app.db)
        
        try await app.test(.GET, usersURI, afterResponse: { response async throws in
            XCTAssertEqual(response.status, .ok)
            let users = try response.content.decode([User].self)
              
            XCTAssertEqual(users.count, 1)
            XCTAssertEqual(users[0].email, user.email)
            XCTAssertEqual(users[0].passwordHash, user.passwordHash)
            XCTAssertEqual(users[0].role, user.role)
            XCTAssertEqual(users[0].id, user.id)
        })
    }
    
    func testUserCanBeSavedWithAPI() async throws {
        let user = User.Create(
            email: "stanga@stanga.com",
            password: "12345678",
            confirmPassword: "12345678",
            role: .user
        )
        
        try await app.test(.POST, usersURI, beforeRequest: { req async throws in
            try req.content.encode(user)
        }, afterResponse: { response async throws in
            let receivedUser = try response.content.decode(User.self)

            XCTAssertEqual(receivedUser.email, user.email)
            let verifiedPassword = try Bcrypt.verify(user.password, created: receivedUser.passwordHash)
            XCTAssertTrue(verifiedPassword)
            XCTAssertEqual(receivedUser.role, user.role)
            XCTAssertNotNil(receivedUser.id)
            
            try await app.test(.GET, usersURI, afterResponse: { response async throws in
                let users = try response.content.decode([User].self)
                
                XCTAssertEqual(users.count, 1)
                XCTAssertEqual(users[0].email, receivedUser.email)
                XCTAssertEqual(users[0].passwordHash, receivedUser.passwordHash)
                XCTAssertEqual(users[0].role, receivedUser.role)
                XCTAssertEqual(users[0].id, receivedUser.id)
                
            })
        })
    }
    
    func testCreateUserWithInvalidEmailWithAPI() async throws {
        let user = User.Create(
            email: "stanga",
            password: "12345678",
            confirmPassword: "12345678",
            role: .user
        )
                
        try await app.test(.POST, usersURI, beforeRequest: { req async throws in
            try req.content.encode(user)
        }, afterResponse: { response async throws in
            XCTAssertEqual(response.status, .badRequest)
        })
    }
    
    func testCreateUserWithShortPasswordWithAPI() async throws {
        let user = User.Create(
            email: "stanga",
            password: "1234",
            confirmPassword: "1234",
            role: .user
        )
                
        try await app.test(.POST, usersURI, beforeRequest: { req async throws in
            try req.content.encode(user)
        }, afterResponse: { response async throws in
            XCTAssertEqual(response.status, .badRequest)
        })
    }
    
    func testCreateUserWithPasswordMissmatchWithAPI() async throws {
        let user = User.Create(
            email: "stanga",
            password: "12345678",
            confirmPassword: "87654321",
            role: .user
        )
                
        try await app.test(.POST, usersURI, beforeRequest: { req async throws in
            try req.content.encode(user)
        }, afterResponse: { response async throws in
            XCTAssertEqual(response.status, .badRequest)
        })
    }
    
    func testGettingASingleUserFromTheAPI() async throws {
        let user = try await User.create(on: app.db)

        try await app.test(.GET, "\(usersURI)\(user.id!)", afterResponse: { response async throws in
            let receivedUser = try response.content.decode(User.self)
            
            XCTAssertEqual(receivedUser.email, user.email)
            XCTAssertEqual(receivedUser.passwordHash, user.passwordHash)
            XCTAssertEqual(receivedUser.role, user.role)
            XCTAssertEqual(receivedUser.id, user.id)
        })
    }
    
    func testGettingNonExistentSingleUserFromTheAPI() async throws {
        let userId = 1

        try await app.test(.GET, "\(usersURI)\(userId)", afterResponse: { response async throws in
            XCTAssertEqual(response.status, .notFound)
        })
    }
}
