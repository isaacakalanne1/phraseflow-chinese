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
        .package(name: "Definition", path: "../Definition")
    ],
    targets: [
        .target(
            name: "Study",
            dependencies: [
                "Definition"
            ]
        ),
        .testTarget(
            name: "StudyTests",
            dependencies: ["Study"]
        ),
    ]
)
