// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "EspeakNG",
    platforms: [
        .macOS(.v11),
        .iOS(.v14)
    ],
    products: [
        // The main library product that users will import
        .library(
            name: "EspeakNG",
            targets: ["EspeakNG"]
        ),
    ],
    dependencies: [],
    targets: [
        // C library target - will eventually be a binaryTarget with XCFramework
        .target(
            name: "CEspeakNG",
            dependencies: [],
            path: "Sources/CEspeakNG",
            publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath("include"),
            ]
        ),

        // Swift wrapper target
        .target(
            name: "EspeakNG",
            dependencies: ["CEspeakNG"],
            path: "Sources/EspeakNG",
            resources: [
                // espeak-ng voice and language data
                .copy("Resources/espeak-ng-data")
            ]
        ),

        // Test target
        .testTarget(
            name: "EspeakNGTests",
            dependencies: ["EspeakNG"]
        ),
    ]
)
