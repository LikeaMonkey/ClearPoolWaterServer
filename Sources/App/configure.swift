import Vapor
import NIOSSL
import Fluent
import FluentPostgresDriver

// configures your application
public func configure(_ app: Application) async throws {
    // Serve files from /Public folder
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    app.logger.logLevel = .init(rawValue: Environment.get("LOG_LEVEL")!) ?? .debug
        
    configureDatabase(app)
    
    try await configureMigrations(app)
    
    enableTLS(app)
        
    try routes(app)
}

func configureDatabase(_ app: Application) {
    let databasePort: Int
    if (app.environment == .testing) {
      databasePort = 5433
    } else {
      databasePort = 5432
    }
    
    app.databases.use(
        .postgres(
            configuration: .init(
                hostname: Environment.get("DATABASE_HOST")!,
                port: databasePort,
                username: Environment.get("DATABASE_USERNAME")!,
                tls: .disable // TODO: Implement
            )
        ),
        as: .psql
    )
}

func configureMigrations(_ app: Application) async throws {
    app.migrations.add(User.Migration())
    app.migrations.add(UserToken.Migration())
    app.migrations.add(Pool.Migration())
    app.migrations.add(PoolStatus.Migration())
    app.migrations.add(WaterStatus.Migration())
    app.migrations.add(MaintenanceTask.Migration())
    
    try await app.autoMigrate()
}

func enableTLS(_ app: Application) {
    let homePath = app.directory.workingDirectory
    let certPath = homePath + Environment.get("CERT_PATH")!
    let keyPath = homePath + Environment.get("KEY_PATH")!

    let certs = try! NIOSSLCertificate.fromPEMFile(certPath).map {
        NIOSSLCertificateSource.certificate($0)
    }
    let privateKey = try! NIOSSLPrivateKey(file: keyPath, format: .pem)
    let tls = TLSConfiguration.makeServerConfiguration(
        certificateChain: certs,
        privateKey: .privateKey(privateKey)
    )

    app.http.server.configuration = .init(
        hostname: "127.0.0.1",
        port: 4343,
        supportVersions: [.two],
        tlsConfiguration: tls
    )
}
