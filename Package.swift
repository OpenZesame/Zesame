// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Zesame",
    platforms: [.macOS(.v12), .iOS(.v15)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Zesame",
            targets: ["Zesame"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/Sajjon/EllipticCurveKit.git", .upToNextMinor(from: "1.0.2")),
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", .upToNextMinor(from: "1.4.3")),
        .package(name: "SwiftProtobuf", url: "https://github.com/apple/swift-protobuf.git", from: "1.6.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Zesame",
            dependencies: ["EllipticCurveKit", "CryptoSwift", "SwiftProtobuf"],
            exclude: ["Models/Protobuf/messages.proto"]
        ),
        .testTarget(
            name: "ZesameTests",
            dependencies: ["Zesame"]),
    ]
)