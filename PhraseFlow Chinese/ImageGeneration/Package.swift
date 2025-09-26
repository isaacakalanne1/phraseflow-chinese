// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ImageGeneration",
    platforms: [
        .iOS("17.4")
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "ImageGeneration",
            targets: ["ImageGeneration"]
        ),
        .library(
            name: "ImageGenerationMocks",
            targets: ["ImageGenerationMocks"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk", exact: "12.3.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "ImageGeneration",
            dependencies: [
                .product(name: "FirebaseCore", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk")
            ]
        ),
        .target(
            name: "ImageGenerationMocks",
            dependencies: [
                "ImageGeneration"
            ],
            path: "Mocks"
        ),
        .testTarget(
            name: "ImageGenerationTests",
            dependencies: [
                "ImageGeneration",
                "ImageGenerationMocks"
            ]
        ),
    ]
)
