//
import ArgumentParser

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
