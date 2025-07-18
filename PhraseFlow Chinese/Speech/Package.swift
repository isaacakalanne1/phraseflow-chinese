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
            targets: ["Speech"]),
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
                "MicrosoftCognitiveServicesSpeech"
            ]
        ),
        .testTarget(
            name: "SpeechTests",
            dependencies: ["Speech"]
        ),
    ]
)
