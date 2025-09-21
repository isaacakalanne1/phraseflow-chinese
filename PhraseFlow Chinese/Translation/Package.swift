// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Translation",
    platforms: [
        .iOS("17.4")
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Translation",
            targets: ["Translation"]
        ),
        .library(
            name: "TranslationMocks",
            targets: ["TranslationMocks"]
        ),
    ],
    dependencies: [
        .package(name: "APIRequest", path: "../APIRequest"),
        .package(name: "ReduxKit", path: "../ReduxKit"),
        .package(name: "Localization", path: "../Localization"),
        .package(name: "FTColor", path: "../FTColor"),
        .package(name: "FTFont", path: "../FTFont"),
        .package(name: "FTStyleKit", path: "../FTStyleKit"),
        .package(name: "Settings", path: "../Settings"),
        .package(name: "Speech", path: "../Speech"),
        .package(name: "Story", path: "../Story"),
        .package(name: "Study", path: "../Study"),
        .package(name: "UserLimit", path: "../UserLimit"),
        .package(name: "TextPractice", path: "../TextPractice"),
        .package(name: "TextGeneration", path: "../TextGeneration")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Translation",
            dependencies: [
                "APIRequest",
                "ReduxKit",
                "Localization",
                "FTColor",
                "FTFont",
                "FTStyleKit",
                "Settings",
                "Speech",
                "Story",
                "Study",
                "UserLimit",
                "TextPractice",
                "TextGeneration"
            ]
        ),
        .target(
            name: "TranslationMocks",
            dependencies: [
                "Translation",
                "APIRequest",
                "ReduxKit",
                "Localization",
                "FTColor",
                "FTFont",
                "FTStyleKit",
                "Settings",
                "Speech",
                "Story",
                "Study",
                "TextPractice",
                "TextGeneration",
                .product(name: "TextGenerationMocks", package: "TextGeneration"),
                .product(name: "TextPracticeMocks", package: "TextPractice")
            ],
            path: "Mocks"
        ),
        .testTarget(
            name: "TranslationTests",
            dependencies: [
                "Translation",
                "TranslationMocks",
                "UserLimit",
                .product(name: "UserLimitMocks", package: "UserLimit"),
                .product(name: "SpeechMocks", package: "Speech"),
                .product(name: "TextGenerationMocks", package: "TextGeneration")
            ]
        ),
    ]
)
