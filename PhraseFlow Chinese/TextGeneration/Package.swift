// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TextGeneration",
    platforms: [
        .iOS("17.4")
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "TextGeneration",
            targets: ["TextGeneration"]),
    ],
    dependencies: [
        .package(name: "APIRequest", path: "../APIRequest"),
        .package(name: "Settings", path: "../Settings"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "TextGeneration",
            dependencies: [
                "APIRequest",
                "Settings"
            ]
        ),
        .testTarget(
            name: "TextGenerationTests",
            dependencies: ["TextGeneration"]
        ),
    ]
)
