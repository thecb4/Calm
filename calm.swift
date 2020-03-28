#!/usr/bin/swift sh

import Calm // ./

Calm.Flow.remote = "git@gitlab.com:thecb4/calm.git"

extension Calm {
  struct Shallow: ParsableCommand {
    static var configuration: CommandConfiguration = "Shallow work"
  }
}

Calm.configuration.subcommands += [Calm.Shallow.self]

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

Calm.Shallow.configuration.subcommands += [Calm.Shallow.Test.self]

if #available(macOS 10.13, *) {
  Calm.main()
} else {
  print("Please at least run macOS 10.13")
}
