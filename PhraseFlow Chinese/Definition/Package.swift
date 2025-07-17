// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Definition",
    platforms: [
        .iOS("17.4")
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Definition",
            targets: ["Definition"]),
    ],
    dependencies: [
        .package(name: "Settings", path: "../Settings"),
        .package(name: "Speech", path: "../Speech")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Definition",
            dependencies: [
                "Settings",
                "Speech"
            ]
        ),
        .testTarget(
            name: "DefinitionTests",
            dependencies: ["Definition"]
        ),
    ]
)
