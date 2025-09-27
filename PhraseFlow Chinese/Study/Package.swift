// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Study",
    platforms: [
        .iOS("17.4")
    ],
    products: [
        .library(
            name: "Study",
            targets: ["Study"]
        ),
        .library(
            name: "StudyMocks",
            targets: ["StudyMocks"]
        ),
    ],
    dependencies: [
        .package(name: "Audio", path: "../Audio"),
        .package(url: "https://github.com/isaacakalanne1/reduxkit.git", from: "1.0.1"),
        .package(name: "Localization", path: "../Localization"),
        .package(name: "FTColor", path: "../FTColor"),
        .package(name: "FTFont", path: "../FTFont"),
        .package(name: "FTStyleKit", path: "../FTStyleKit"),
        .package(name: "Settings", path: "../Settings"),
        .package(name: "TextGeneration", path: "../TextGeneration"),
        .package(name: "AppleIcon", path: "../AppleIcon")
    ],
    targets: [
        .target(
            name: "Study",
            dependencies: [
                "Audio",
                "Localization",
                "FTColor",
                "FTFont",
                "FTStyleKit",
                "Settings",
                "TextGeneration",
                "AppleIcon",
                .product(name: "ReduxKit", package: "reduxkit")
            ]
        ),
        .target(
            name: "StudyMocks",
            dependencies: [
                "Study",
                "Audio",
                "Localization",
                "FTColor",
                "FTFont",
                "FTStyleKit",
                "Settings",
                "TextGeneration",
                "AppleIcon",
                .product(name: "SettingsMocks", package: "Settings"),
                .product(name: "TextGenerationMocks", package: "TextGeneration"),
                .product(name: "ReduxKit", package: "reduxkit")
            ],
            path: "Mocks"
        ),
        .testTarget(
            name: "StudyTests",
            dependencies: [
                "Study",
                "StudyMocks"
            ]
        ),
    ]
)
