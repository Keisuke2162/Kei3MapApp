// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Kei3MapAppPackage",
    platforms: [.iOS(.v17)],
    products: [
      .library(name: "Feature", targets: ["Feature"]),
    ],
    dependencies: [
      .package(url: "https://github.com/firebase/firebase-ios-sdk", exact: "11.6.0"),
      .package(url: "https://github.com/google/GoogleSignIn-iOS", exact: "8.0.0"),
      .package(url: "https://github.com/onevcat/Kingfisher.git", exact: "8.1.2"),
    ],
    targets: [
      .target(name: "Entity"),
      .target(name: "Extensions"),
      .target(name: "Feature", dependencies: [
        "Entity",
        "Extensions",
        "Repository",
        "Services",
        .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
        .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
        .product(name: "FirebaseStorage", package: "firebase-ios-sdk"),
        .product(name: "GoogleSignIn", package: "GoogleSignIn-iOS"),
        .product(name: "Kingfisher", package: "Kingfisher")
      ]),
      .target(name: "Repository", dependencies: [
        "Entity",
        "Extensions",
        .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
        .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
        .product(name: "FirebaseStorage", package: "firebase-ios-sdk"),
        .product(name: "GoogleSignIn", package: "GoogleSignIn-iOS"),
      ]),
      .target(name: "Services"),
    ]
)
