// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Zesame",
    platforms: [.macOS(.v10_15), .iOS(.v13)],
    products: [
        .library(
            name: "Zesame",
            targets: ["Zesame"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Sajjon/EllipticCurveKit.git", .upToNextMinor(from: "1.0.2")),
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", .upToNextMajor(from: "1.8.0")),
        .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "6.7.0"),
        .package(url: "https://github.com/apple/swift-protobuf.git", from: "1.26.0"),
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.9.0")),
    ],
    targets: [
        .target(
            name: "Zesame",
            dependencies: [
                "EllipticCurveKit",
                "CryptoSwift",
                "RxSwift",
                .product(name: "SwiftProtobuf", package: "swift-protobuf"),
                "Alamofire",
            ],
            exclude: ["Models/Protobuf/messages.proto"],
            swiftSettings: [
                .swiftLanguageMode(.v5),
            ]
        ),
        .testTarget(
            name: "ZesameTests",
            dependencies: ["Zesame"],
            swiftSettings: [
                .swiftLanguageMode(.v5),
            ]
        ),
    ]
)
