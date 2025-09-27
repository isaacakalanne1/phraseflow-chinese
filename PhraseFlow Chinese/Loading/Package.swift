// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Loading",
    platforms: [
        .iOS("17.4")
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Loading",
            targets: ["Loading"]
        ),
        .library(
            name: "LoadingMocks",
            targets: ["LoadingMocks"]
        ),
    ],
    dependencies: [
        .package(name: "FTColor", path: "../FTColor"),
        .package(name: "FTFont", path: "../FTFont"),
        .package(name: "Localization", path: "../Localization"),
        .package(url: "https://github.com/isaacakalanne1/reduxkit.git", from: "1.0.1")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Loading",
            dependencies: [
                "FTColor",
                "FTFont",
                "Localization",
                .product(name: "ReduxKit", package: "reduxkit")
            ]
        ),
        .target(
            name: "LoadingMocks",
            dependencies: [
                "Loading",
                "FTColor",
                "FTFont",
                "Localization",
                .product(name: "ReduxKit", package: "reduxkit")
            ],
            path: "Mocks"
        ),
        .testTarget(
            name: "LoadingTests",
            dependencies: [
                "Loading",
                "LoadingMocks"
            ]
        ),
    ]
)
