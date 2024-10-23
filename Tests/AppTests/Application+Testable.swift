//
//  Application+Testable.swift
//  ClearPoolWaterServer
//
//  Created by Stanimir Hristov on 22.10.24.
//

import XCTVapor
import App

extension Application {
  static func testable() async throws -> Application {
    let app = try await Application.make(.testing)
    try await configure(app)
      
    try await app.autoRevert()
    try await app.autoMigrate()
      
    return app
  }
}
