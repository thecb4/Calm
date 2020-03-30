//
import Path
import ShellKit
import ArgumentParser

@available(macOS 10.13, *)
public struct Calm: ParsableCommand {
  public static var configuration = CommandConfiguration(
    abstract: "A utility for performing command line work",
    subcommands: [
      Init.self,
      Feature.self,
      Release.self,
      Work.self
    ],
    defaultSubcommand: Work.self
  )

  public static var remote: String?

  public init() {}
}

@available(macOS 10.13, *)
extension Calm {
  public static let env = ["PATH": "/usr/local/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"]
  public static let gitPreCommitHookPath = Path.cwd / ".git/hooks/pre-commit"
  public static let gitPreCommitShellScript =
    """
    #!/bin/bash
    # Stops accidental commits to master and develop. https://gist.github.com/stefansundin/9059706

    BRANCH=`git rev-parse --abbrev-ref HEAD`

    branches=(develop master)

    if [[ " ${branches[@]} " =~ " ${BRANCH} "  ]]; then
      echo "You are on branch $BRANCH. Are you sure you want to commit to this branch?"
      echo "If so, commit with -n to bypass this pre-commit hook."
      exit 1
    fi

    exit 0
    """
  public static let calmScriptPath = Path.cwd
  public static let calmScript =
    """
    // 
    import Calm // ./

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
    """
}
