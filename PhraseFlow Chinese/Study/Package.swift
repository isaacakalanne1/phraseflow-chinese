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
            targets: ["Study"]),
    ],
    dependencies: [
        .package(name: "Audio", path: "../Audio"),
        .package(name: "ReduxKit", path: "../ReduxKit"),
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
                "ReduxKit",
                "Localization",
                "FTColor",
                "FTFont",
                "FTStyleKit",
                "Settings",
                "TextGeneration",
                "AppleIcon"
            ]
        ),
        .testTarget(
            name: "StudyTests",
            dependencies: ["Study"]
        ),
    ]
)
