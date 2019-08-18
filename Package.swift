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
        .package(
            url: "https://github.com/apple/swift-protobuf.git",
            from: "1.5.0"),
        .package(
            url: "https://github.com/Boilertalk/secp256k1.swift",
            from: "0.0.0"),
    ],
    targets: [
        .target(
            name: "MPSCSwift",
            dependencies: []),
        .testTarget(
            name: "MPSCSwiftTests",
            dependencies: ["MPSCSwift"]),
        .systemLibrary(
            name: "zmq",
            pkgConfig: "libzmq",
            providers: [
                .brew(["zeromq"]),
                .apt(["libzmq-dev"]),
            ]),
        .target(
            name: "ZeroMQSwift",
            dependencies: ["zmq"]),
        .testTarget(
            name: "ZeroMQSwiftTests",
            dependencies: ["ZeroMQSwift"]),
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
