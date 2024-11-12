//
//  LoginAPITests.swift
//  ClearPoolWaterServer
//
//  Created by Stanimir Hristov on 24.10.24.
//

import XCTVapor
import JWTKit
@testable import App

final class LoginAPITests: XCTestCase {
    let loginURI = "/login/"
    var app: Application!
    
    override func setUp() async throws {
        app = try await Application.testable()
    }
    
    override func tearDown() async throws {
        try await self.app.asyncShutdown()
        self.app = nil
    }
    
    func testSuccessUserLoginFromAPI() async throws {
        let email = "stanga@stanga.com"
        let password = "12345678"
        _ = try await User.create(
            email: email,
            password: password,
            on: app.db
        )
        
        let basicAuth = APIUtils.createBasicAuth(email: email, password: password)
        let headers = APIUtils.basicAuthHeaders(with: basicAuth)
        try await app.test(.POST, loginURI, headers: headers, afterResponse: { response async throws in
            XCTAssertEqual(response.status, .ok)
            let tokenResponse = try response.content.decode(ClientTokenResponse.self)
            XCTAssertFalse(tokenResponse.token.isEmpty)
        })
    }
}
