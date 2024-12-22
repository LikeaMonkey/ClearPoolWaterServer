import Vapor
import NIOSSL
import Fluent
import FluentPostgresDriver
import JWT

// configures your application
public func configure(_ app: Application) async throws {
    // Serve files from /Public folder
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    app.logger.logLevel = .init(rawValue: Environment.get("LOG_LEVEL")!) ?? .debug
    
    // Add HMAC with SHA-256 signer.
    // TODO: Be sure to replace "secret" with an actual secret key.
    // This key should be kept secure, ideally in a configuration file or environment variable.
    await app.jwt.keys.add(hmac: "secret", digestAlgorithm: .sha256)
        
    configureDatabase(app)
    
    try await configureMigrations(app)
    
    enableTLS(app)
        
    try routes(app)
}

func configureDatabase(_ app: Application) throws {
    // Production database
    if let databaseURL = Environment.get("DATABASE_URL") {
        var tlsConfig: TLSConfiguration = .makeClientConfiguration()
        tlsConfig.certificateVerification = .none
        let nioSSLContext = try NIOSSLContext(configuration: tlsConfig)

        var postgresConfig = try SQLPostgresConfiguration(url: databaseURL)
        postgresConfig.coreConfiguration.tls = .require(nioSSLContext)

        app.databases.use(.postgres(configuration: postgresConfig), as: .psql)
        
        return
    }
    
    // Development/Testing local databases
    let databasePort: Int
    if app.environment == .testing {
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
    app.migrations.add(Pool.Migration())
    app.migrations.add(PoolStatus.Migration())
    app.migrations.add(WaterStatus.Migration())
        
    if app.environment != .production {
        try await app.autoMigrate()
    }
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
