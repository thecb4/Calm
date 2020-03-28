
import Foundation
import Calm // ./

@available(macOS 10.13, *)
extension Calm {
  struct Shallow: ParsableCommand {
    static var configuration: CommandConfiguration = "Shallow work"
  }
}

@available(macOS 10.13, *)
extension Calm.Shallow {
  struct Test: ParsableCommand {
    public static var configuration: CommandConfiguration = "Run tests"

    public func run() throws {
      try Shell.swiftTestGenerateLinuxMain()
      try Shell.swiftFormat(version: "5.1")

      let arguments = [
        "--parallel",
        "--xunit-output Tests/Results.xml",
        "--enable-code-coverage"
      ]

      try Shell.swiftTest(arguments: arguments)
    }
  }
}

@available(macOS 10.13, *)
extension Shell.Path {
  /// Returns path to the built products directory.
  public static var productsDirectory: Path {
    Path(url: Bundle.main.bundleURL)!
  }

//  public static var testFixturesDirectory: Path {
//    packageDirectory / "Tests/fixtures"
//  }

  public static var projectDirectory: Path {
    // necessary if you are using xcode
    Path(url: URL(fileURLWithPath: #file))!
      .parent
      .parent
      .parent
  }
}

if #available(macOS 10.13, *) {
  Shell.Path.cwd = Shell.Path.projectDirectory.string

  Calm.Shallow.configuration.subcommands += [Calm.Shallow.Test.self]

  Calm.Flow.remote = "git@gitlab.com:thecb4/calm.git"

  let arguments = [
    "work", "local-integration"
  ]

  try Calm.run(using: arguments)

} else {
  print("Please at least run macOS 10.13")
}
