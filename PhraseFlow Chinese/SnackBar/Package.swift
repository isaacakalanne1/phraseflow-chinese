// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SnackBar",
    platforms: [
        .iOS("17.4")
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SnackBar",
            targets: ["SnackBar"]
        ),
        .library(
            name: "SnackBarMocks",
            targets: ["SnackBarMocks"]
        ),
    ],
    dependencies: [
        .package(name: "Audio", path: "../Audio"),
        .package(name: "ReduxKit", path: "../ReduxKit"),
        .package(name: "Localization", path: "../Localization"),
        .package(name: "Loading", path: "../Loading"),
        .package(name: "FTColor", path: "../FTColor")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "SnackBar",
            dependencies: [
                "Audio",
                "Localization",
                "Loading",
                "ReduxKit",
                "FTColor"
            ]
        ),
        .target(
            name: "SnackBarMocks",
            dependencies: [
                "SnackBar",
                "Audio",
                "Localization",
                "Loading",
                "ReduxKit",
                "FTColor"
            ],
            path: "Mocks"
        ),
        .testTarget(
            name: "SnackBarTests",
            dependencies: [
                "SnackBar",
                "SnackBarMocks"
            ]
        ),
    ]
)
