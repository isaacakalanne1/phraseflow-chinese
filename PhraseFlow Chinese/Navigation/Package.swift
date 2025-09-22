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
            targets: ["Navigation"]
        ),
        .library(
            name: "NavigationMocks",
            targets: ["NavigationMocks"]
        )
    ],
    dependencies: [
        .package(name: "Localization", path: "../Localization"),
        .package(name: "AppleIcon", path: "../AppleIcon"),
        .package(name: "FTColor", path: "../FTColor"),
        .package(name: "Study", path: "../Study"),
        .package(name: "Story", path: "../Story"),
        .package(name: "Audio", path: "../Audio"),
        .package(name: "Loading", path: "../Loading"),
        .package(name: "Settings", path: "../Settings"),
        .package(name: "Subscription", path: "../Subscription"),
        .package(name: "SnackBar", path: "../SnackBar"),
        .package(name: "Translation", path: "../Translation"),
        .package(name: "UserLimit", path: "../UserLimit"),
        .package(name: "DataStorage", path: "../DataStorage"),
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
                "FTColor",
                "Study",
                "Story",
                "Audio",
                "Loading",
                "Settings",
                "Subscription",
                "SnackBar",
                "Translation",
                "UserLimit",
                "DataStorage",
                "ReduxKit"
            ]
        ),
        .target(
            name: "NavigationMocks",
            dependencies: [
                "Navigation",
                "Study",
                "Audio",
                "Loading",
                "Settings",
                "Subscription",
                "Translation",
                "DataStorage",
                .product(name: "AudioMocks", package: "Audio"),
                .product(name: "SettingsMocks", package: "Settings"),
                .product(name: "SubscriptionMocks", package: "Subscription"),
                .product(name: "Story", package: "Story"),
                .product(name: "StoryMocks", package: "Story"),
                .product(name: "StudyMocks", package: "Study"),
                .product(name: "LoadingMocks", package: "Loading"),
                .product(name: "TranslationMocks", package: "Translation"),
                .product(name: "UserLimitMocks", package: "UserLimit")
            ],
            path: "Mocks"
        ),
        .testTarget(
            name: "NavigationTests",
            dependencies: [
                "Navigation",
                "NavigationMocks",
                "Localization",
                .product(name: "SnackBarMocks", package: "SnackBar")
            ]
        ),
    ]
)
