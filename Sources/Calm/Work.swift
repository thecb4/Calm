//
import ArgumentParser

@available(macOS 10.13, *)
extension Calm {
  struct Work: ParsableCommand {
    public static var configuration = CommandConfiguration(
      abstract: "Manage work flow",
      subcommands: [
        Hygene.self,
        Test.self,
        Save.self,
        Documentation.self,
        LocalIntegration.self,
        ContinuousIntegration.self
        // Finish.self
      ],
      defaultSubcommand: Hygene.self
    )
  }
}

@available(macOS 10.13, *)
extension Calm.Work {
  struct Hygene: ParsableCommand {
    public static var configuration: CommandConfiguration = "Perform hygene activities on the project"

    public func run() throws {
      try ShellKit.validate(Shell.exists(at: "commit.yml"), "You need to add a commit.yml file")
      try ShellKit.validate(!Shell.git_ls_untracked.contains("commit.yml"), "You need to track commit file")
      try ShellKit.validate(Shell.git_ls_modified.contains("commit.yml"), "You need to update your commit file")
    }
  }

  struct Test: ParsableCommand {
    public static var configuration: CommandConfiguration = "Run tests"

    public func run() throws {
      try Shell.swiftTestGenerateLinuxMain(environment: env)
      try Shell.swiftFormat(version: "5.1", environment: env)

      let arguments = [
        "--parallel",
        "--xunit-output Tests/Results.xml",
        "--enable-code-coverage"
      ]

      try Shell.swiftTest(arguments: arguments)
      print("Hello World")
      print("Goodbye World")
    }
  }

  struct Save: ParsableCommand {
    public static var configuration: CommandConfiguration = "git commit activities"

    public func run() throws {
      try Hygene.run()
      try Shell.changelogger(arguments: ["log"])
      try Shell.git(arguments: ["add", "-A"])
      try Shell.git(arguments: ["commit", "-F", "commit.yml"])
    }
  }

  struct Documentation: ParsableCommand {
    public static var configuration: CommandConfiguration = "Generate Documentation"

    public func run() throws {
      try Shell.swiftDoc(
        name: "ShellKit",
        output: "docs",
        author: "Cavelle Benjamin",
        authorUrl: "https://thecb4.io",
        twitterHandle: "_thecb4",
        gitRepository: "https://github.com/thecb4/ShellKit"
      )
    }
  }

  struct LocalIntegration: ParsableCommand {
    public static var configuration = "Perform local integration"

    @Flag(help: "Save on integration completion")
    var save: Bool

    public func run() throws {
      // try Hygene.run()
      try Test.run()
      // if save { try Save.run() }
    }
  }

  struct ContinuousIntegration: ParsableCommand {
    public static var configuration: CommandConfiguration = "Perform continous integration"

    public func run() throws {
      try Test.run()
    }
  }
}
