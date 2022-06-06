// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "runah",
  platforms: [
    .macOS(.v10_12)
  ],
  products: [
    .executable(
      name: "runah",
      targets: ["runah"]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0"),
  ],
  targets: [
    .executableTarget(
      name: "runah",
      dependencies: [
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
      ]
    ),
    .testTarget(
      name: "runahTests",
      dependencies: ["runah"]
    ),
  ]
)
