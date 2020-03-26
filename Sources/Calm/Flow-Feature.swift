//
import ArgumentParser
import ShellKit

@available(macOS 10.13, *)
extension Calm.Flow.Feature {
  public struct Start: ParsableCommand {
    public static var configuration: CommandConfiguration = "Create a feature branch"

    @Argument(help: "Feature name")
    var name: String

    public func run() throws {
      try ShellKit.validate(Shell.git_current_branch != "master", "cannot create feature branch from master")
      print("starting a feature named \(name)")
      try Shell.git(arguments: ["checkout", "-b", "\(Calm.Flow.Feature.prefix)/\(name)", "develop"])
    }

    public init() {}
  }

  public struct Pull: ParsableCommand {
    public static var configuration = "Get latest for a feature branch"

    @Argument(
      default: Shell.git_current_branch.replacingOccurrences(of: "\(Calm.Flow.Feature.prefix)/", with: ""),
      help: "Feature name"
    )
    var name: String

    public func run() throws {
      print("pull latest for feature: \(name) from origin")
      // try Shell.git(arguments: ["checkout", "feature/MYFEATURE"])
      // try Shell.git(arguments: ["pull", "--rebase", "origin", "feature/MYFEATURE"])
    }

    public init() {}
  }

  public struct Finish: ParsableCommand {
    public static var configuration: CommandConfiguration = "Finalize a feature branch"

    @Argument(
      default: Shell.git_current_branch.replacingOccurrences(of: "\(Calm.Flow.Feature.prefix)/", with: ""),
      help: "Feature name"
    )
    var name: String

    public func run() throws {
      try ShellKit.validate(Shell.git_clean_branch, "Dirty branch! Clean it up")
      print("finalize feature: \(name)")
      try Shell.git(arguments: ["checkout", "develop"])
      try Shell.git(arguments: ["merge", "--no-ff", "\(Calm.Flow.Feature.prefix)/\(name)"])
      try Shell.git(arguments: ["branch", "-d", "\(Calm.Flow.Feature.prefix)/\(name)"])
    }

    public init() {}
  }

  public struct Publish: ParsableCommand {
    public static var configuration: CommandConfiguration = "Publish a feature branch"

    @Argument(
      default: Shell.git_current_branch.replacingOccurrences(of: "\(Calm.Flow.Feature.prefix)/", with: ""),
      help: "Feature name"
    )
    var name: String

    public func run() throws {
      print("publish feature: \(name)")
      try Shell.git(arguments: ["checkout", "\(Calm.Flow.Feature.prefix)/\(name)"])
      try Shell.git(arguments: ["push", "origin", "\(Calm.Flow.Feature.prefix)/\(name)"])
    }

    public init() {}
  }
}
