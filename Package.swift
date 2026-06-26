// swift-tools-version: 6.3.1

import PackageDescription

let package = Package(
    name: "swift-memory-sequence-primitives",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26),
    ],
    products: [
        .library(
            name: "Memory Sequence Primitives",
            targets: ["Memory Sequence Primitives"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-primitives/swift-memory-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-span-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-memory-cursor-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-sequence-primitives.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "Memory Sequence Primitives",
            dependencies: [
                .product(name: "Memory Primitive", package: "swift-memory-primitives"),
                .product(name: "Span Protocol Primitives", package: "swift-span-primitives"),
                .product(name: "Memory Cursor Primitives", package: "swift-memory-cursor-primitives"),
                .product(name: "Sequence Protocol Primitives", package: "swift-sequence-primitives"),
            ]
        ),
        .testTarget(
            name: "Memory Sequence Primitives Tests",
            dependencies: ["Memory Sequence Primitives"]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("LifetimeDependence"),
        .enableExperimentalFeature("Lifetimes"),
        .enableExperimentalFeature("SuppressedAssociatedTypes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
    ]

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem
}
