//
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
