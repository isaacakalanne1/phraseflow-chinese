// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Story",
    platforms: [
        .iOS("17.4")
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Story",
            targets: ["Story"]),
    ],
    dependencies: [
        .package(url: "git@git-gdd.sdo.jlrmotor.com:OFFBOARD/mobile/libraries/ios/kits/reduxkit.git", .upToNextMajor(from: "4.1.2")),
        .package(name: "FTColor", path: "../FTColor"),
        .package(name: "FTFont", path: "../FTFont"),
        .package(name: "Loading", path: "../Loading"),
        .package(name: "Media", path: "../Media"),
        .package(name: "Speech", path: "../Speech"),
        .package(name: "Settings", path: "../Settings"),
        .package(name: "TextGeneration", path: "../TextGeneration")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Story",
            dependencies: [
                .product(name: "ReduxKit", package: "ReduxKit"),
                "FTColor",
                "FTFont",
                "Loading",
                "Media",
                "Speech",
                "Settings",
                "TextGeneration"
            ]
        ),
        .testTarget(
            name: "StoryTests",
            dependencies: ["Story"]
        ),
    ]
)
