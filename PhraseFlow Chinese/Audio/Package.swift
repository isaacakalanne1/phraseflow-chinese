// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Audio",
    platforms: [
        .iOS("17.4")
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Audio",
            targets: ["Audio"]
        ),
        .library(
            name: "AudioMocks",
            targets: ["AudioMocks"]
        ),
    ],
    dependencies: [
        .package(name: "ReduxKit", path: "../ReduxKit")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Audio",
            dependencies: [
                "ReduxKit"
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .target(
            name: "AudioMocks",
            dependencies: [
                "Audio",
                "ReduxKit"
            ],
            path: "Mocks"
        ),
        .testTarget(
            name: "AudioTests",
            dependencies: [
                "Audio",
                "AudioMocks"
            ]
        ),
    ]
)
