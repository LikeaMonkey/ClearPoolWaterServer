import Vapor

func routes(_ app: Application) throws {
    let passwordProtected = app.grouped(
        User.authenticator(),
        User.guardMiddleware()
    )
    passwordProtected.post("login") { req async throws -> ClientTokenResponse in
        let user = try req.auth.require(User.self)
        let payload = try SessionToken(with: user)
        return ClientTokenResponse(token: try await req.jwt.sign(payload))
    }
    
    let secure = app.grouped(
        SessionToken.authenticator(),
        SessionToken.guardMiddleware()
    )
    secure.get("me") { req -> User in
        let sessionToken = try req.auth.require(SessionToken.self)
        guard let user = try await User.find(sessionToken.userId, on: req.db) else {
            throw Abort(.notFound)
        }
        
        app.logger.debug("Validated logged in user: \(user)")

        return user
    }
    
    try app.register(collection: UsersController())
    try app.register(collection: PoolsController())
    try app.register(collection: PoolStatusController())
    try app.register(collection: WaterStatusController())
    try app.register(collection: PoolTasksController())
}
