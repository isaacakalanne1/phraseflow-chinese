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
        .package(name: "FTColor", path: "../FTColor"),
        .package(name: "FTFont", path: "../FTFont"),
        .package(name: "Settings", path: "../Settings"),
        .package(name: "Speech", path: "../Speech"),
        .package(name: "Story", path: "../Story"),
        .package(name: "ReduxKit", path: "../ReduxKit"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Definition",
            dependencies: [
                "FTColor",
                "FTFont",
                "Settings",
                "Speech",
                "Story",
                .product(name: "ReduxKit", package: "ReduxKit")
            ]
        ),
        .testTarget(
            name: "DefinitionTests",
            dependencies: ["Definition"]
        ),
    ]
)
