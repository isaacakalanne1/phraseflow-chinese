// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Subscription",
    platforms: [
        .iOS("17.4")
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Subscription",
            targets: ["Subscription"]),
    ],
    dependencies: [
        .package(name: "ReduxKit", path: "../ReduxKit"),
        .package(name: "Localization", path: "../Localization"),
        .package(name: "FTColor", path: "../FTColor"),
        .package(name: "FTFont", path: "../FTFont"),
        .package(name: "Speech", path: "../Speech"),
        .package(name: "UserLimit", path: "../UserLimit"),
        .package(name: "Settings", path: "../Settings"),
        .package(name: "DataStorage", path: "../DataStorage")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Subscription",
            dependencies: [
                "ReduxKit",
                "Localization",
                "FTColor",
                "FTFont",
                "Speech",
                "UserLimit",
                "Settings",
                "DataStorage"
            ]),
        .testTarget(
            name: "SubscriptionTests",
            dependencies: ["Subscription"]
        ),
    ]
)
