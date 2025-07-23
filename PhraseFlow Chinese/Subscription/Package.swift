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
        .package(name: "Navigation", path: "../Navigation"),
        .package(name: "Localization", path: "../Localization"),
        .package(name: "FTColor", path: "../FTColor"),
        .package(name: "FTFont", path: "../FTFont")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Subscription",
            dependencies: [
                "ReduxKit",
                "Navigation",
                "Localization",
                "FTColor",
                "FTFont"
            ]),
        .testTarget(
            name: "SubscriptionTests",
            dependencies: ["Subscription"]
        ),
    ]
)
