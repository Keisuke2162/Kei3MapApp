// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Kei3MapAppPackage",
    platforms: [.iOS(.v17)],
    products: [
      .library(name: "Feature", targets: ["Feature"]),
    ],
    dependencies: [],
    targets: [
      .target(name: "Entity"),
      .target(name: "Extensions"),
      .target(name: "Feature", dependencies: [
        "Entity",
        "Extensions"
      ]),
    ]
)
