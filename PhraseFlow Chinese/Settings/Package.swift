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
            targets: ["Settings"]),
    ],
    dependencies: [
        .package(url: "git@git-gdd.sdo.jlrmotor.com:OFFBOARD/mobile/libraries/ios/kits/reduxkit.git", .upToNextMajor(from: "4.1.2")),
        .package(name: "Localization", path: "../Localization"),
        .package(name: "FTColor", path: "../FTColor"),
        .package(name: "FTFont", path: "../FTFont")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Settings",
            dependencies: [
                .product(name: "ReduxKit", package: "ReduxKit"),
                "Localization",
                "FTColor",
                "FTFont"
            ]),
        .testTarget(
            name: "SettingsTests",
            dependencies: ["Settings"]
        ),
    ]
)
