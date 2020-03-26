//
import ArgumentParser

@available(macOS 10.13, *)
public struct Calm: ParsableCommand {
  public static var configuration = CommandConfiguration(
    abstract: "A utility for performing command line work",
    subcommands: [
      Flow.self,
      Work.self
    ],
    defaultSubcommand: Work.self
  )

  public init() {}
}
