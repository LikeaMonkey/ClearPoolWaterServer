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
    var expiration: ExpirationClaim

    init(userId: Int, admin: Bool) {
        self.userId = userId
        self.admin = admin
        self.expiration = ExpirationClaim(value: Expiration.date)
    }

    init(with user: User) throws {
        self.userId = try user.requireID()
        self.admin = user.role == .admin
        self.expiration = ExpirationClaim(value: Expiration.date)
    }

    func verify(using algorithm: some JWTAlgorithm) throws {
        try expiration.verifyNotExpired()
    }
    
    private struct Expiration {
        static var time: TimeInterval { 60 * 60 * 24 } // One day
        static var date: Date { Date().addingTimeInterval(time) }
    }
}
