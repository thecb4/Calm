#!/usr/bin/swift sh

import ArgumentParser // apple/swift-argument-parser == 0.0.4
import ShellKit // thecb4/shellkit  == master
import Version // mxcl/Version == 2.0.0

// import SigmaSwiftStatistics evgenyneu/SigmaSwiftStatistics == master

let env = ["PATH": "/usr/local/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"]

extension Version: ExpressibleByArgument {}

extension ParsableCommand {
  static func run(using arguments: [String] = []) throws {
    let command = try parseAsRoot(arguments)
    try command.run()
  }
}

extension CommandConfiguration: ExpressibleByStringLiteral {
  public init(stringLiteral value: String) {
    self.init(abstract: value)
  }
}

struct Calm: ParsableCommand {
  static var configuration = CommandConfiguration(
    abstract: "A utility for performing command line work",
    subcommands: [
      Test.self,
      Hygene.self,
      LocalIntegration.self,
      ContinuousIntegration.self,
      Save.self,
      Release.self,
      Documentation.self,
      Flow.self
    ],
    defaultSubcommand: Hygene.self
  )
}

extension Calm {
  struct Hygene: ParsableCommand {
    static var configuration: CommandConfiguration = "Perform hygene activities on the project"

    func run() throws {
      try ShellKit.validate(Shell.exists(at: "commit.yml"), "You need to add a commit.yml file")
      try ShellKit.validate(!Shell.git_ls_untracked.contains("commit.yml"), "You need to track commit file")
      try ShellKit.validate(Shell.git_ls_modified.contains("commit.yml"), "You need to update your commit file")
    }
  }

  struct Test: ParsableCommand {
    static var configuration: CommandConfiguration = "Run tests"

    func run() throws {
      try Shell.swiftTestGenerateLinuxMain(environment: env)
      try Shell.swiftFormat(version: "5.1", environment: env)

      var arguments = [
        "--parallel",
        "--xunit-output Tests/Results.xml",
        "--enable-code-coverage"
      ]

      #if os(Linux)
        arguments += ["--filter \"^(?!.*MacOS).*$\""]
      #endif

      try Shell.swiftTest(arguments: arguments)
    }
  }

  struct Save: ParsableCommand {
    static var configuration = "git commit activities"

    func run() throws {
      try Hygene.run()
      try Shell.changelogger(arguments: ["log"])
      try Shell.git(arguments: ["add", "-A"])
      try Shell.git(arguments: ["commit", "-F", "commit.yml"])
    }
  }

  struct LocalIntegration: ParsableCommand {
    static var configuration: CommandConfiguration = "Perform local integration"

    @Flag(help: "Save on integration completion")
    var save: Bool

    func run() throws {
      try Hygene.run()
      try Test.run()
      if save { try Save.run() }
    }
  }

  struct ContinuousIntegration: ParsableCommand {
    static var configuration: CommandConfiguration = "Perform continous integration"

    func run() throws {
      try Test.run()
    }
  }

  struct Documentation: ParsableCommand {
    static var configuration: CommandConfiguration = "Generate Documentation"

    func run() throws {
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
}

extension Calm {
  struct Release: ParsableCommand {
    static var configuration = CommandConfiguration(
      abstract: "Release of work",
      subcommands: [
        New.self,
        Prepare.self,
        Publish.self
      ],
      defaultSubcommand: New.self
    )
  }
}

extension Calm.Release {
  struct New: ParsableCommand {
    static var configuration: CommandConfiguration = "creates new release (tag)"
    // TO-DO: move to an option group
    @Argument(help: "version for the release")
    var version: Version

    func run() {
      print("new release \(version)")
    }
  }

  struct Prepare: ParsableCommand {
    static var configuration = "prepare the current release"

    @Argument(help: "summary of the release to prepare")
    var summary: String

    @Argument(help: "version for the release")
    var version: Version

    func run() throws {
      let files = try Shell.git(arguments: ["status", "--untracked-files=no", "--porcelain"])
      try ShellKit.validate(files.out == "", "Dirt repository. Clean it up before preparing your release")

      try Shell.changelogger(arguments: ["release", "\"\(summary)\"", "--version-tag", version.description], environment: env)
      try Shell.changelogger(arguments: ["markdown"])

      try Shell.git(arguments: ["add", "-A"])
      try Shell.git(arguments: ["commit", "-F", "commit.yml"])
    }
  }

  struct Publish: ParsableCommand {
    @Argument(help: "version for the release")
    var version: Version

    func run() {
      print("new release \(version)")
    }
  }
}

extension Calm {
  struct Flow: ParsableCommand {
    static var configuration = CommandConfiguration(
      abstract: "Git flow commands",
      subcommands: [
        Init.self,
        Feature.self,
        Release.self
      ],
      defaultSubcommand: Init.self
    )
  }
}

extension Calm.Flow {
  struct Init: ParsableCommand {
    static var configuration = "Initialize flow"

    func run() throws {
      print("flow init")
      try Shell.git(arguments: ["init"])
      try Shell.git(arguments: ["commit", "--allow-empty", "-m", "\"Initial commit\""])
      try Shell.git(arguments: ["checkout", "-b", "develop", "master"])
    }
  }

  struct Feature: ParsableCommand {
    static var configuration = CommandConfiguration(
      abstract: "Manage git flow features",
      subcommands: [
        Start.self,
        Publish.self,
        Pull.self,
        Finish.self
      ],
      defaultSubcommand: Start.self
    )

    struct Options: ParsableArguments {
      // @Flag(name: [.customLong("hex-output"), .customShort("x")],
      //       help: "Use hexadecimal notation for the result.")
      // var hexadecimalOutput: Bool

      @Argument(
          help: "Feature name")
      var name: String
    }
  }

  struct Release: ParsableCommand {
    static var configuration = CommandConfiguration(
      abstract: "Manage git flow releases",
      subcommands: [
        Start.self,
        Publish.self,
        // Pull.self,
        Finish.self
      ],
      defaultSubcommand: Start.self
    )

    struct Options: ParsableArguments {
      // @Flag(name: [.customLong("hex-output"), .customShort("x")],
      //       help: "Use hexadecimal notation for the result.")
      // var hexadecimalOutput: Bool

      @Argument(
          help: "Semantic Version")
      var version: Version
    }

  }

  struct Work: ParsableCommand {
    static var configuration: CommandConfiguration = "Work"


  }
}

extension Calm.Flow.Feature {
  struct Start: ParsableCommand {
    static var configuration = "Create a feature branch"

    // The `@OptionGroup` attribute includes the flags, options, and
    // arguments defined by another `ParsableArguments` type.
    @OptionGroup()
    var options: Calm.Flow.Feature.Options

    func run() throws {
      //try Shell.git(arguments: ["checkout", "-b", "feature/MYFEATURE", "develop"])
      print("starting a feature named \(options.name)")
    }
  }

  struct Pull: ParsableCommand {
    static var configuration = "Get latest for a feature branch"

    // The `@OptionGroup` attribute includes the flags, options, and
    // arguments defined by another `ParsableArguments` type.
    @OptionGroup()
    var options: Calm.Flow.Feature.Options

    func run() throws {
      print("pull latest for feature: \(options.name) from origin")
      //try Shell.git(arguments: ["checkout", "feature/MYFEATURE"])
      //try Shell.git(arguments: ["pull", "--rebase", "origin", "feature/MYFEATURE"])
    }
  }

  struct Finish: ParsableCommand {
    static var configuration = "Finalize a feature branch"

    // The `@OptionGroup` attribute includes the flags, options, and
    // arguments defined by another `ParsableArguments` type.
    @OptionGroup()
    var options: Calm.Flow.Feature.Options

    func run() throws {
      print("finalize feature: \(options.name)")
      //try Shell.git(arguments: ["checkout", "develop"])
      //try Shell.git(arguments: ["merge", "--no-ff", "feature/MYFEATURE"])
      //try Shell.git(arguments: ["branch", "-d", "feature/MYFEATURE"])
    }
  }

  struct Publish: ParsableCommand {
    static var configuration = "Publish a feature branch"

    // The `@OptionGroup` attribute includes the flags, options, and
    // arguments defined by another `ParsableArguments` type.
    @OptionGroup()
    var options: Calm.Flow.Feature.Options

    func run() throws {
      print("publish feature: \(options.name)")
      //try Shell.git(arguments: ["checkout", "feature/MYFEATURE"])
      //try Shell.git(arguments: ["push", "origin", "feature/MYFEATURE"])
    }
  }
}

extension Calm.Flow.Release {
  struct Start: ParsableCommand {
    static var configuration = "Create a release branch"

    // The `@OptionGroup` attribute includes the flags, options, and
    // arguments defined by another `ParsableArguments` type.
    @OptionGroup()
    var options: Calm.Flow.Release.Options

    func run() throws {
      //try Shell.git(arguments: ["checkout", "-b", "release/version", "develop"])
      print("starting release: \(options.version)")
    }
  }

  // struct Pull: ParsableCommand {
  //   static var configuration = "Get latest for a release branch"
  //
  //   func run() throws {
  //     print("pull latest for a release from origin")
  //     //try Shell.git(arguments: ["checkout", "release/version"])
  //     //try Shell.git(arguments: ["pull", "--rebase", "origin", "release/version"])
  //   }
  // }

  struct Finish: ParsableCommand {
    static var configuration = "Finalize a release branch"

    // The `@OptionGroup` attribute includes the flags, options, and
    // arguments defined by another `ParsableArguments` type.
    @OptionGroup()
    var options: Calm.Flow.Release.Options

    func run() throws {
      print("finalize release: \(options.version)")
      //try Shell.git(arguments: ["checkout", "master"])
      //try Shell.git(arguments: ["merge", "--no-ff", "release/version"])
      //try Shell.git(arguments: ["tag", "-a", "version"])
      //try Shell.git(arguments: ["checkout", "develop"])
      //try Shell.git(arguments: ["merge", "--no-ff", "release/version"])
      //try Shell.git(arguments: ["branch", "-d", "release/version"])
    }
  }

  struct Publish: ParsableCommand {
    static var configuration = "Publish a release branch"

    // The `@OptionGroup` attribute includes the flags, options, and
    // arguments defined by another `ParsableArguments` type.
    @OptionGroup()
    var options: Calm.Flow.Release.Options

    func run() throws {
      print("publish release: \(options.version)")
      //try Shell.git(arguments: ["checkout", "develop"])
      //try Shell.git(arguments: ["push", "origin", "develop"])
      //try Shell.git(arguments: ["push", "origin", "--tags"])
      //try Shell.git(arguments: ["push", "origin", "master"])
    }
  }
}

// extension Calm.Work {
//   struct Test: ParsableCommand {
//     static var configuration: CommandConfiguration = "Run tests"
//
//     func run() throws {
//       try Shell.swiftTestGenerateLinuxMain(environment: env)
//       try Shell.swiftFormat(version: "5.1", environment: env)
//
//       var arguments = [
//         "--parallel",
//         "--xunit-output Tests/Results.xml",
//         "--enable-code-coverage"
//       ]
//
//       #if os(Linux)
//         arguments += ["--filter \"^(?!.*MacOS).*$\""]
//       #endif
//
//       try Shell.swiftTest(arguments: arguments)
//     }
//   }
// }
//
// Calm.Work.configuration.subcommands += [Test.Self]

Calm.main()
