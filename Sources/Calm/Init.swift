//
import ArgumentParser
import ShellKit
import Version

@available(macOS 10.13, *)
extension Calm {
  public struct Init: ParsableCommand {
    public static var configuration: CommandConfiguration = "Initialize calmness"

    public func run() throws {
      print("flow init")
      try Shell.git(arguments: ["init"])
      try Shell.git(arguments: ["commit", "--allow-empty", "-m", "\"Initial commit\""])
      try Calm.gitPreCommitShellScript.write(to: Calm.gitPreCommitHookPath)
      try Calm.gitPreCommitHookPath.chmod(0o754)
      try Calm.calmScript.write(to: Calm.calmScriptPath)
      try Shell.git(arguments: ["checkout", "-b", "develop", "master"])
      if let remote = Calm.remote {
        try Shell.git(arguments: ["remote", "add", "origin", remote])
      }
    }

    public init() {}
  }
}
