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
            targets: ["Navigation"]),
    ],
    dependencies: [
        .package(name: "Localization", path: "../Localization"),
        .package(name: "AppleIcon", path: "../AppleIcon"),
        .package(url: "git@git-gdd.sdo.jlrmotor.com:OFFBOARD/mobile/libraries/ios/kits/reduxkit.git", .upToNextMajor(from: "4.1.2")),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Navigation",
            dependencies: [
                "Localization",
                "AppleIcon",
                .product(name: "ReduxKit", package: "ReduxKit")
            ]),
        .testTarget(
            name: "NavigationTests",
            dependencies: ["Navigation"]
        ),
    ]
)
