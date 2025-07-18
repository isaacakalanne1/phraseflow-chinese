// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Navigation",
    platforms: [
        .iOS("17.4")
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Navigation",
            targets: ["Navigation"]),
    ],
    dependencies: [
        .package(name: "Localization", path: "../Localization"),
        .package(name: "AppleIcon", path: "../AppleIcon"),
        .package(name: "Story", path: "../Story"),
        .package(name: "Audio", path: "../Audio"),
        .package(name: "ReduxKit", path: "../ReduxKit"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Navigation",
            dependencies: [
                "Localization",
                "AppleIcon",
                "Story",
                "Audio",
                .product(name: "ReduxKit", package: "ReduxKit")
            ]),
        .testTarget(
            name: "NavigationTests",
            dependencies: ["Navigation"]
        ),
    ]
)
