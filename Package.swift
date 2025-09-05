// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftUIPresentation",
    platforms: [.iOS(.v17), .macOS(.v14), .tvOS(.v17), .watchOS(.v10)],
    products: [
        .library(name: "SwiftUIPresentation", targets: ["SwiftUIPresentation"]),
    ],
    dependencies: [
        .package(url: "https://github.com/stalkermv/SwiftHelpers.git", from: "1.0.0"),
        .package(url: "https://github.com/stalkermv/SwiftUIHelpers.git", from: "1.0.0"),
        // UI inspection & interaction testing (development only)
        .package(url: "https://github.com/nalexn/ViewInspector.git", from: "0.9.13"),
        // Documentation generation
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "SwiftUIPresentation",
            dependencies: [
                .product(name: "SwiftUIHelpers", package: "SwiftUIHelpers"),
                .product(name: "Development", package: "SwiftHelpers"),
            ],
            swiftSettings: [
                .enableUpcomingFeature("ExistentialAny"),
                .enableUpcomingFeature("StrictConcurrency"),
            ]
        ),
        .testTarget(
            name: "SwiftUIPresentationTests",
            dependencies: [
                "SwiftUIPresentation",
                .product(name: "ViewInspector", package: "ViewInspector")
            ],
            swiftSettings: [
                .enableUpcomingFeature("ExistentialAny"),
                .enableUpcomingFeature("StrictConcurrency"),
            ]
        ),
    ]
)
