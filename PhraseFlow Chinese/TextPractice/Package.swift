// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TextPractice",
    platforms: [
        .iOS("17.4")
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "TextPractice",
            targets: ["TextPractice"]),
    ],
    dependencies: [
        .package(name: "Audio", path: "../Audio"),
        .package(name: "FTFont", path: "../FTFont"),
        .package(name: "FTStyleKit", path: "../FTStyleKit"),
        .package(name: "Settings", path: "../Settings"),
        .package(name: "Study", path: "../Study"),
        .package(name: "TextGeneration", path: "../TextGeneration"),
        .package(name: "Localization", path: "../Localization")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "TextPractice",
            dependencies: [
                "Audio",
                "FTFont",
                "FTStyleKit",
                "Settings",
                "Study",
                "TextGeneration",
                "Localization"
            ]
        ),
        .testTarget(
            name: "TextPracticeTests",
            dependencies: ["TextPractice"]
        ),
    ]
)
