//
//  SessionToken.swift
//  ClearPoolWaterServer
//
//  Created by Stanimir Hristov on 26.10.24.
//

import Vapor
import JWT

struct SessionToken: Content, Authenticatable, JWTPayload {
    var userId: Int
    var admin: Bool
    var expiration = ExpirationClaim(value: Expiration.date)

    init(with user: User) throws {
        userId = try user.requireID()
        admin = user.role == .admin
    }

    func verify(using algorithm: some JWTAlgorithm) throws {
        try expiration.verifyNotExpired()
    }
    
    private struct Expiration {
        static var date: Date { Date().addingTimeInterval(oneDay) }
        static var oneDay: TimeInterval { 60 * 60 * 24 }
    }
}
