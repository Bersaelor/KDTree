// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "KDTree",
    products: [
        .executable(
            name: "KDTree",
            targets: ["KDTree"]
        )
    ],
    targets: [
        .target(
            name: "KDTree",
            path: "Sources"
        )
    ]
)
