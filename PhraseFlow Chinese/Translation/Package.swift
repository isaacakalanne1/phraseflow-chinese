// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Translation",
    platforms: [
        .iOS("17.4")
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Translation",
            targets: ["Translation"]),
    ],
    dependencies: [
        .package(name: "Localization", path: "../Localization"),
        .package(name: "FTColor", path: "../FTColor"),
        .package(name: "FTFont", path: "../FTFont"),
        .package(name: "Settings", path: "../Settings")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Translation",
            dependencies: [
                "Localization",
                "FTColor",
                "FTFont",
                "Settings"
            ]),
        .testTarget(
            name: "TranslationTests",
            dependencies: ["Translation"]
        ),
    ]
)
