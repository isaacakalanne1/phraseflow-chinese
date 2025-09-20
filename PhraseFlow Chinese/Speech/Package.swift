// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Speech",
    platforms: [
        .iOS("17.4")
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Speech",
            targets: ["Speech"]
        ),
        .library(
            name: "SpeechMocks",
            targets: ["SpeechMocks"]
        ),
    ],
    dependencies: [
        .package(name: "TextGeneration", path: "../TextGeneration"),
        .package(name: "Settings", path: "../Settings")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .binaryTarget(
            name: "MicrosoftCognitiveServicesSpeech",
            path: "Frameworks/MicrosoftCognitiveServicesSpeech.xcframework"
        ),
        .target(
            name: "Speech",
            dependencies: [
                "MicrosoftCognitiveServicesSpeech",
                "TextGeneration",
                "Settings"
            ]
        ),
        .target(
            name: "SpeechMocks",
            dependencies: [
                "Speech",
                "MicrosoftCognitiveServicesSpeech",
                "Settings",
                "TextGeneration",
                .product(name: "TextGenerationMocks", package: "TextGeneration")
            ],
            path: "Mocks"
        ),
        .testTarget(
            name: "SpeechTests",
            dependencies: [
                .product(name: "Speech", package: "Speech"),
                .product(name: "SpeechMocks", package: "Speech"),
                .product(name: "TextGeneration", package: "TextGeneration"),
                .product(name: "TextGenerationMocks", package: "TextGeneration")
            ]
        ),
    ]
)
