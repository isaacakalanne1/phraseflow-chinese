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
        .package(name: "Settings", path: "../Settings"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk", exact: "12.3.0")
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
                "Settings",
                .product(name: "FirebaseCore", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk")
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
                "Speech",
                "SpeechMocks",
                .product(name: "TextGeneration", package: "TextGeneration"),
                .product(name: "TextGenerationMocks", package: "TextGeneration")
            ]
        ),
    ]
)
