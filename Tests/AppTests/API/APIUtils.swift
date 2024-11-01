//
//  APIUtils.swift
//  ClearPoolWaterServer
//
//  Created by Stanimir Hristov on 26.10.24.
//

import XCTVapor

struct APIUtils {
    static func basicAuthHeaders(with basic: String) -> HTTPHeaders {
        ["Authorization": basic]
    }
    
    static func jwtBearerHeaders(with token: String) -> HTTPHeaders {
        ["Authorization": "Bearer \(token)"]
    }
    
    static func createBasicAuth(email: String, password: String) -> String {
        let loginString = String(format: "%@:%@", email, password)
        let loginData = loginString.data(using: String.Encoding.utf8)!
        let base64LoginString = loginData.base64EncodedString()

        return "Basic \(base64LoginString)"
    }
}
