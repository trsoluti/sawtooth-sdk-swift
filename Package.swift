// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "SawtoothSDKSwift",
    products: [
        .library(
            name: "SawtoothSigning",
            targets: ["SawtoothSigning"]),
        .library(
            name: "SawtoothSDKSwift",
            targets: ["SawtoothSDKSwift"]),
        .library(
            name: "SawtoothProtoSwift",
            targets: ["SawtoothProtoSwift"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-protobuf.git", from: "1.5.0"),
        .package(url: "https://github.com/Boilertalk/secp256k1.swift", from: "0.0.0"),
        .package(url: "Support/MPSCSwift", from: "0.0.1"),
        .package(url: "Support/ZeroMQSwift", from: "0.0.1"),
    ],
    targets: [
        .target(
            name: "SawtoothSigning",
            dependencies: ["secp256k1"]),
        .target(
            name: "SawtoothProtoSwift",
            dependencies: ["SwiftProtobuf"]),
        .target(
            name: "SawtoothSDKSwift",
            dependencies: ["MPSCSwift", "ZeroMQSwift", "SawtoothProtoSwift"]),
        .testTarget(
            name: "SawtoothSigningTests",
            dependencies: ["SawtoothSigning"]),
        .testTarget(
            name: "SawtoothSDKSwiftTests",
            dependencies: ["SawtoothSDKSwift"]),
    ]
)
