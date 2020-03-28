//
import ArgumentParser
import ShellKit
import Version

@available(macOS 10.13, *)
extension Calm {
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

@available(macOS 10.13, *)
extension Calm.Release {
  public struct Start: ParsableCommand {
    public static var configuration: CommandConfiguration = "Create a release branch"

    @Argument(
      default: Version(Shell.git_current_branch.replacingOccurrences(of: "\(Calm.Release.prefix)/", with: "")),
      help: "Release version"
    )
    var version: Version

    public func run() throws {
      print("starting release: \(version)")
      try Shell.git(arguments: ["checkout", "-b", "\(Calm.Release.prefix)/\(version)", "develop"])
    }

    public init() {}
  }

  public struct Bump: ParsableCommand {
    public static var configuration: CommandConfiguration = "Create a release branch"

    @Argument(
      default: .exact,
      help: "Release version"
    )
    var value: Version.ReleaseBump

    @Argument(help: "Release version")
    var version: Version?

    @Option(help: "Pre-release data")
    var preRelease: String?

    @Option(help: "Build data")
    var buildMeta: String?

    public func run() throws {
      guard let current = Version(from: Version.path) else { throw CleanExit.message("Check your .version file") }
      print("current version is \(current), bumping \(value)")

      var next: Version = .null

      if case .exact = value {
        guard let update = version else { throw CleanExit.message("exact requires semantic version X.Y.Z") }
        next = update
      } else {
        next = current.bump(value, pre: preRelease?.components(separatedBy: "."), build: buildMeta?.components(separatedBy: "."))
      }

      print("next version is \(next)")
      try Shell.git(arguments: ["checkout", "-b", "\(Calm.Release.prefix)/\(next)", "develop"])
      try next.write(to: Version.path)
    }

    public init() {}
  }

  public struct Prepare: ParsableCommand {
    public static var configuration: CommandConfiguration = "prepare the current release"

    @Argument(help: "summary of the release to prepare")
    var summary: String

    @Argument(help: "version for the release")
    var version: Version

    public func run() throws {
      let files = try Shell.git(arguments: ["status", "--untracked-files=no", "--porcelain"])
      try ShellKit.validate(files.out == "", "Dirt repository. Clean it up before preparing your release")

      try Shell.changelogger(arguments: ["release", "\"\(summary)\"", "--version-tag", version.description], environment: env)
      try Shell.changelogger(arguments: ["markdown"])

      try Shell.git(arguments: ["add", "-A"])
      try Shell.git(arguments: ["commit", "-F", "commit.yml"])
    }

    public init() {}
  }

  public struct Finish: ParsableCommand {
    public static var configuration: CommandConfiguration = "Finalize a release branch"

    @Argument(
      default: Version(Shell.git_current_branch.replacingOccurrences(of: "\(Calm.Release.prefix)/", with: "")),
      help: "Release version"
    )
    var version: Version

    public func run() throws {
      try ShellKit.validate(Shell.git_clean_branch, "Dirty branch! Clean it up")
      print("finalize release: \(version)")
      try Shell.git(arguments: ["checkout", "master"])
      try Shell.git(arguments: ["merge", "--no-ff", "\(Calm.Release.prefix)/\(version)"])
      try Shell.git(arguments: ["tag", "-a", "\(version)", "-m", "\"Release \(version)\""])
      try Shell.git(arguments: ["checkout", "develop"])
      try Shell.git(arguments: ["merge", "--no-ff", "\(Calm.Release.prefix)/\(version)"])
      try Shell.git(arguments: ["branch", "-d", "\(Calm.Release.prefix)/\(version)"])
    }

    public init() {}
  }

  public struct Publish: ParsableCommand {
    public static var configuration: CommandConfiguration = "Publish a release branch"

    public func run() throws {
      print("publish recent releases")
      try Shell.git(arguments: ["checkout", "develop"])
      try Shell.git(arguments: ["push", "origin", "develop"])
      try Shell.git(arguments: ["push", "--tags"])
      try Shell.git(arguments: ["push", "origin", "master"])
    }

    public init() {}
  }
}
