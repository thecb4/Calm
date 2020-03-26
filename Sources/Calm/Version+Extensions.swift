//
import ArgumentParser
import Foundation
import Path
import Version

extension Version {
  public enum ReleaseBump: String, Codable, ExpressibleByArgument {
    case major, minor, patch, exact
  }
}

extension Version: ExpressibleByArgument {}

extension Version {
  public static var path: Path = Path.cwd / ".version"

  public init?(from path: Path) {
    let decoder = JSONDecoder()

    guard let string = try? String(contentsOf: path) else { return nil }

    guard let data = string.data(using: .utf8) else { return nil }

    guard let version = try? decoder.decode(Version.self, from: data) else { return nil }

    self = version
  }

  public func write(to path: Path) throws {
    let encoder = JSONEncoder()
    let data = try encoder.encode(self)
    let string = String(data: data, encoding: .utf8)
    try string?.write(to: path, encoding: .utf8)
  }
}

extension Version {
  public func bump(_ bump: Version.ReleaseBump, pre: [String]? = nil, build: [String]? = nil) -> Version {
    switch bump {
      case .patch: return Version(major, minor, patch + 1, pre: pre ?? prereleaseIdentifiers, build: build ?? buildMetadataIdentifiers)
      case .minor: return Version(major, minor + 1, 0, pre: pre ?? prereleaseIdentifiers, build: build ?? buildMetadataIdentifiers)
      case .major: return Version(major + 1, 0, 0, pre: pre ?? prereleaseIdentifiers, build: build ?? buildMetadataIdentifiers)
      default: return Version(major, minor, patch, pre: pre ?? prereleaseIdentifiers, build: build ?? buildMetadataIdentifiers)
    }
  }
}
