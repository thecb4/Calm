#!/usr/bin/swift sh

import Calm // ./

Calm.Flow.remote = "git@gitlab.com:thecb4/calm.git"

// extension Calm {
//   struct Shallow: ParsableCommand {
//     static var configuration: CommandConfiguration = "Shallow work"
//   }
// }
//
// Calm.configuration.subcommands += [Shallow.self]
//
// extension Calm.Shallow {
//   struct Test: ParsableCommand {
//     public static var configuration: CommandConfiguration = "Run tests"
//
//     public func run() throws {
//       try Shell.swiftTestGenerateLinuxMain(environment: env)
//       try Shell.swiftFormat(version: "5.1", environment: env)
//
//       let arguments = [
//         "--parallel",
//         "--xunit-output Tests/Results.xml",
//         "--enable-code-coverage"
//       ]
//
//       try Shell.swiftTest(arguments: arguments)
//     }
//   }
// }
//
// Calm.Shallow.configuration.subcommands += [Test.self]

if #available(macOS 10.13, *) {
  Calm.main()
} else {
  print("Please at least run macOS 10.13")
}
