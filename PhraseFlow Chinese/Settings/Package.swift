// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Settings",
    platforms: [
        .iOS("17.4")
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Settings",
            targets: ["Settings"]
        ),
        .library(
            name: "SettingsMocks",
            targets: ["SettingsMocks"]
        ),
    ],
    dependencies: [
        .package(name: "Audio", path: "../Audio"),
        .package(url: "https://github.com/isaacakalanne1/reduxkit.git", from: "1.0.1"),
        .package(name: "Localization", path: "../Localization"),
        .package(name: "FTColor", path: "../FTColor"),
        .package(name: "FTFont", path: "../FTFont"),
        .package(name: "FTStyleKit", path: "../FTStyleKit"),
        .package(name: "SnackBar", path: "../SnackBar"),
        .package(name: "UserLimit", path: "../UserLimit"),
        .package(name: "DataStorage", path: "../DataStorage"),
        .package(name: "Moderation", path: "../Moderation")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Settings",
            dependencies: [
                "Audio",
                "Localization",
                "FTColor",
                "FTFont",
                "FTStyleKit",
                "SnackBar",
                "UserLimit",
                "DataStorage",
                "Moderation",
                .product(name: "ReduxKit", package: "reduxkit")
            ]
        ),
        .target(
            name: "SettingsMocks",
            dependencies: [
                "Settings",
                "Localization",
                "FTColor",
                "FTFont",
                "FTStyleKit",
                "SnackBar",
                "UserLimit",
                "DataStorage",
                "Moderation",
                .product(name: "ReduxKit", package: "reduxkit"),
                .product(name: "Audio", package: "Audio"),
                .product(name: "AudioMocks", package: "Audio"),
                .product(name: "ModerationMocks", package: "Moderation")
            ],
            path: "Mocks"
        ),
        .testTarget(
            name: "SettingsTests",
            dependencies: [
                "Settings",
                "SettingsMocks",
                .product(name: "ReduxKit", package: "reduxkit"),
                .product(name: "Audio", package: "Audio"),
                .product(name: "AudioMocks", package: "Audio"),
                .product(name: "ModerationMocks", package: "Moderation")
            ]
        ),
    ]
)
