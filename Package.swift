// swift-tools-version:4.0
// swiftlint:disable:previous file_header

import PackageDescription

// swiftlint:disable:next explicit_top_level_acl
let package = Package(
    name: "RxWebSocket",
    products: [
        .library(
            name: "RxWebSocket",
            targets: ["RxWebSocket"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/ReactiveX/RxSwift.git",
            .upToNextMajor(from: "5.0.0")
        ),
        .package(
            url: "https://github.com/daltoniam/Starscream.git",
            .upToNextMajor(from: "3.1.0")
        )
    ],
    targets: [
        .target(
            name: "RxWebSocket",
            dependencies: ["RxSwift", "RxCocoa", "Starscream"],
            path: "Classes"
        ),
        .testTarget(
            name: "RxWebSocketTests",
            dependencies: [
                "RxWebSocket",
                "RxSwift",
                "RxCocoa",
                "Starscream",
                "RxBlocking"
            ],
            path: "RxWebSocketTests"
        )
    ]
)
