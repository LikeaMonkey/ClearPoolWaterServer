//
//  UserToken.swift
//  ClearPoolWaterServer
//
//  Created by Stanimir Hristov on 10.10.24.
//

import Vapor
import Fluent

final class UserToken: Model, Content, @unchecked Sendable {
    static let schema = "user_tokens"

    @ID(custom: "id", generatedBy: .database)
    var id: Int?

    @Field(key: "value")
    var value: String

    @Parent(key: "user_id")
    var user: User

    init() { }

    init(id: Int? = nil, value: String, userID: User.IDValue) {
        self.id = id
        self.value = value
        self.$user.id = userID
    }
}

extension UserToken: ModelTokenAuthenticatable {
    static let valueKey = \UserToken.$value
    static let userKey = \UserToken.$user

    var isValid: Bool {
        true
    }
}
