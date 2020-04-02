// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Calm",
  products: [
    // Products define the executables and libraries produced by a package, and make them visible to other packages.
    .library(name: "Calm", targets: ["Calm"])
  ],
  dependencies: [
    // Dependencies declare other packages that this package depends on.
    // .package(url: /* package url */, from: "1.0.0"),
    .package(url: "https://github.com/apple/swift-argument-parser.git", .exact("0.0.4")),
    .package(url: "https://github.com/mxcl/Path.swift.git", .exact("1.0.0")),
    .package(url: "https://github.com/mxcl/Version.git", .exact("2.0.0")),
    .package(url: "https://github.com/thecb4/ShellKit.git", .exact("0.3.0"))
  ],
  targets: [
    .target(
      name: "Calm",
      dependencies: [
        "ArgumentParser",
        "Path",
        // .product(name: "ArgumentParser", package: "swift-argument-parser"),
        // .product(name: "Path", package: "Path.swift"),
        "Version",
        "ShellKit"
      ]
    ),
    .target(
      name: "TestHelpers",
      dependencies: [
        "ArgumentParser",
        "Path"
        // .product(name: "ArgumentParser", package: "swift-argument-parser"),
        // .product(name: "Path", package: "Path.swift")
      ],
      path: "Tests/Helpers"
    ),
    .testTarget(
      name: "CalmTests",
      dependencies: [
        "Calm",
        "TestHelpers",
        "Path"
        // .product(name: "Path", package: "Path.swift")
      ]
    )
  ]
)
