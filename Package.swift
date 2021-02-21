// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Zesame",
    platforms: [.macOS(.v10_15), .iOS(.v13)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Zesame",
            targets: ["Zesame"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/Sajjon/EllipticCurveKit.git", .upToNextMinor(from: "1.0.2")),
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", .upToNextMinor(from: "1.3.8")),
        .package(url: "https://github.com/ReactiveX/RxSwift.git", .exact("6.1.0")),
        .package(name: "SwiftProtobuf", url: "https://github.com/apple/swift-protobuf.git", from: "1.6.0"),
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.2.0")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Zesame",
            dependencies: ["EllipticCurveKit", "CryptoSwift", "RxSwift", "SwiftProtobuf", "Alamofire"],
            exclude: ["Models/Protobuf/messages.proto"]
        ),
        .testTarget(
            name: "ZesameTests",
            dependencies: ["Zesame"]),
    ]
)
