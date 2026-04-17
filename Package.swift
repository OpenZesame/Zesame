// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Zesame",
    platforms: [.macOS(.v11), .iOS(.v13)],
    products: [
        .library(
            name: "Zesame",
            targets: ["Zesame"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Sajjon/K1.git", from: "0.3.7"),
        .package(url: "https://github.com/attaswift/BigInt.git", from: "5.2.1"),
        .package(url: "https://github.com/apple/swift-protobuf.git", from: "1.26.0"),
    ],
    targets: [
        .target(
            name: "Zesame",
            dependencies: [
                "K1",
                "BigInt",
                .product(name: "SwiftProtobuf", package: "swift-protobuf"),
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
