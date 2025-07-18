// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "UserLimit",
    platforms: [
        .iOS("17.4")
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "UserLimit",
            targets: ["UserLimit"]),
    ],
    dependencies: [
        .package(name: "ReduxKit", path: "../ReduxKit")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "UserLimit",
            dependencies: [
                .product(name: "ReduxKit", package: "ReduxKit")
            ]),
        .testTarget(
            name: "UserLimitTests",
            dependencies: ["UserLimit"]
        ),
    ]
)
