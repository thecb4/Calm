//
import ArgumentParser
import ShellKit
import Version

@available(macOS 10.13, *)
extension Calm {
  public struct Flow: ParsableCommand {
    public static var configuration = CommandConfiguration(
      abstract: "Git flow commands",
      subcommands: [
        Init.self,
        Feature.self,
        Work.self,
        Release.self
      ],
      defaultSubcommand: Init.self
    )

    public static var remote: String?

    public init() {}
  }
}

@available(macOS 10.13, *)
extension Calm.Flow {
  public struct Init: ParsableCommand {
    public static var configuration: CommandConfiguration = "Initialize flow"

    public func run() throws {
      print("flow init")
      try Shell.git(arguments: ["init"])
      try Shell.git(arguments: ["commit", "--allow-empty", "-m", "\"Initial commit\""])
      try gitPreCommitShellScript.write(to: gitPreCommitHookPath)
      try gitPreCommitHookPath.chmod(0o754)
      try Shell.git(arguments: ["checkout", "-b", "develop", "master"])
      if let remote = Calm.Flow.remote {
        try Shell.git(arguments: ["remote", "add", "origin", remote])
      }
    }

    public init() {}
  }

  public struct Feature: ParsableCommand {
    public static var configuration = CommandConfiguration(
      abstract: "Manage git flow features",
      subcommands: [
        Start.self,
        Publish.self,
        Pull.self,
        Finish.self
      ],
      defaultSubcommand: Start.self
    )

    static var prefix: String = "feature"

    public init() {}
  }

  public struct Release: ParsableCommand {
    public static var configuration = CommandConfiguration(
      abstract: "Manage git flow releases",
      subcommands: [
        Start.self,
        Bump.self,
        Publish.self,
        Prepare.self,
        Finish.self
      ],
      defaultSubcommand: Start.self
    )

    static var prefix: String = "release"

    public init() {}
  }
}
