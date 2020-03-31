//
import ShellKit

@available(macOS 10.13, *)
extension Shell {
  public static var git_current_branch: String {
    let arguments = ["rev-parse", "--abbrev-ref", "HEAD"]

    guard let result = try? Shell.git(arguments: arguments, workingDirectory: Shell.Path.cwd, logLevel: .off) else {
      return ""
    }

    if result.status == 0 {
      return result.out
    } else {
      return ""
    }
  }
}

@available(macOS 10.13, *)
extension Shell {
  public static var git_clean_branch: Bool {
    guard let files = try? Shell.git(arguments: ["status", "--porcelain"]) else { return false }
    return files.out == ""
  }
}
