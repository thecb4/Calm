// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Calm",
  products: [
    // Products define the executables and libraries produced by a package, and make them visible to other packages.
    .library(name: "Calm", targets: ["Calm"])
    // .library(name: "CalmCLI", targets: ["CalmCLI"]),
    // .executable(name: "calm", targets: ["CalmExecutable"])
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
    // Targets are the basic building blocks of a package. A target can define a module or a test suite.
    // Targets can depend on other targets in this package, and on products in packages which this package depends on.
    // .target(
    //     name: "CalmExecutable",
    //     dependencies: ["CalmKit"]
    // ),
    // .target(
    //     name: "CalmCLI",
    //     dependencies: ["ArgumentParser", "Path", "CalmKit", "ShellKit"]
    // ),
    .target(
      name: "Calm",
      dependencies: ["ArgumentParser", "Path", "Version", "ShellKit"]
    ),
    .target(
      name: "TestHelpers",
      dependencies: ["ArgumentParser", "Path"],
      path: "Tests/Helpers"
    ),
    // .testTarget(
    //     name: "CalmTests",
    //     dependencies: ["CalmExecutable", "TestHelpers"]
    // ),
    // .testTarget(
    //     name: "CalmCLITests",
    //     dependencies: ["CalmCLI", "ArgumentParser", "TestHelpers", "Path"]
    // ),
    .testTarget(
      name: "CalmTests",
      dependencies: ["Calm", "TestHelpers", "Path"]
    )
  ]
)
