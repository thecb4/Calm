// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Calm",
  products: [
    // Products define the executables and libraries produced by a package, and make them visible to other packages.
    .library(name: "Calm", targets: ["Calm"]),
    .executable(name: "calmX", targets: ["CalmX"])
  ],
  dependencies: [
    // Dependencies declare other packages that this package depends on.
    // .package(url: /* package url */, from: "1.0.0"),
    .package(url: "https://github.com/apple/swift-argument-parser.git", .exact("0.0.4")),
    .package(url: "https://github.com/mxcl/Path.swift.git", .exact("1.0.0")),
    .package(url: "https://github.com/mxcl/Version.git", .exact("2.0.0")),
    .package(url: "https://github.com/thecb4/ShellKit.git", .branch("2630153a"))
  ],
  targets: [
    .target(
      name: "Calm",
      dependencies: ["ArgumentParser", "Path", "Version", "ShellKit"]
    ),
    .target(
      name: "CalmX",
      dependencies: ["Calm"]
    ),
    .target(
      name: "TestHelpers",
      dependencies: ["ArgumentParser", "Path"],
      path: "Tests/Helpers"
    ),
    .testTarget(
      name: "CalmTests",
      dependencies: ["Calm", "TestHelpers", "Path"]
    )
  ]
)
