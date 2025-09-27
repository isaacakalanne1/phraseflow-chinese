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
        .package(url: "https://github.com/isaacakalanne1/reduxkit.git", from: "1.0.1")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Audio",
            dependencies: [
                .product(name: "ReduxKit", package: "reduxkit")
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .target(
            name: "AudioMocks",
            dependencies: [
                "Audio",
                .product(name: "ReduxKit", package: "reduxkit")
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
