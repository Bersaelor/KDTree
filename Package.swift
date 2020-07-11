// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.
//
//  Package.swift
//
// Copyright (c) 2020 mathHeartCode UG(haftungsbeschränkt) <konrad@mathheartcode.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import PackageDescription

let package = Package(
    name: "KDTree",
    platforms: [
        .iOS(SupportedPlatform.IOSVersion.v8),
        .macOS(SupportedPlatform.MacOSVersion.v10_10),
        .tvOS(SupportedPlatform.TVOSVersion.v9),
        .watchOS(SupportedPlatform.WatchOSVersion.v4)
    ], // .linux doesn't need the supported platform definition
    products: [
        .library(
            name: "KDTree",
            targets: ["KDTree"]
        )
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
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
