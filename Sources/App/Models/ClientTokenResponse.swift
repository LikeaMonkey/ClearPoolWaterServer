//
//  ClientTokenResponse.swift
//  ClearPoolWaterServer
//
//  Created by Stanimir Hristov on 26.10.24.
//

import Vapor

struct ClientTokenResponse: Content {
    var token: String
}
