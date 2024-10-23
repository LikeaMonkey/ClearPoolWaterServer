import Vapor

func routes(_ app: Application) throws {
    let passwordProtected = app.grouped(User.authenticator())
    passwordProtected.post("login") { req async throws -> UserToken in
        let user = try req.auth.require(User.self)
        let token = try user.generateToken()
        try await token.save(on: req.db)
        
        user.lastLogin = Date()
        try await user.update(on: req.db)
        
        return token
    }
    
    let protected = app
        .grouped(UserToken.authenticator())
        .grouped(User.guardMiddleware())
    protected.get("me") { req -> User in
        try req.auth.require(User.self)
    }
    
    try app.register(collection: UsersController())
    try app.register(collection: PoolsController())
    try app.register(collection: PoolStatusController())
    try app.register(collection: WaterStatusController())
}
