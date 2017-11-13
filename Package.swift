// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "KDTree",
    products: [
        .library(
            name: "KDTree",
            targets: ["KDTree"]
        )
    ],
    targets: [
        .target(
            name: "KDTree",
            path: "Sources"
        ),
        .testTarget(
            name: "KDTreeTests",
            dependencies: ["KDTree"]
        )
    ]
)
