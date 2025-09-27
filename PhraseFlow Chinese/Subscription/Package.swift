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
            targets: ["Subscription"]
        ),
        .library(
            name: "SubscriptionMocks",
            targets: ["SubscriptionMocks"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/isaacakalanne1/reduxkit.git", from: "1.0.1"),
        .package(name: "Localization", path: "../Localization"),
        .package(name: "FTColor", path: "../FTColor"),
        .package(name: "FTFont", path: "../FTFont"),
        .package(name: "Speech", path: "../Speech"),
        .package(name: "UserLimit", path: "../UserLimit"),
        .package(name: "Settings", path: "../Settings"),
        .package(name: "SnackBar", path: "../SnackBar"),
        .package(name: "DataStorage", path: "../DataStorage")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Subscription",
            dependencies: [
                "Localization",
                "FTColor",
                "FTFont",
                "Speech",
                "SnackBar",
                "UserLimit",
                "Settings",
                "DataStorage",
                .product(name: "ReduxKit", package: "reduxkit")
            ]
        ),
        .target(
            name: "SubscriptionMocks",
            dependencies: [
                "Subscription",
                "Localization",
                "FTColor",
                "FTFont",
                "Speech",
                "UserLimit",
                "Settings",
                "SnackBar",
                .product(name: "SnackBarMocks", package: "SnackBar"),
                .product(name: "SettingsMocks", package: "Settings"),
                "DataStorage",
                .product(name: "ReduxKit", package: "reduxkit")
            ],
            path: "Mocks"
        ),
        .testTarget(
            name: "SubscriptionTests",
            dependencies: [
                "Subscription",
                "SubscriptionMocks",
                "Settings",
                .product(name: "ReduxKit", package: "reduxkit"),
                .product(name: "SpeechMocks", package: "Speech"),
                .product(name: "SettingsMocks", package: "Settings"),
                .product(name: "UserLimitMocks", package: "UserLimit")
            ]
        ),
    ]
)
