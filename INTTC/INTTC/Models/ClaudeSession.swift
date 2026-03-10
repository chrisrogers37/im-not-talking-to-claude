import Foundation

struct ClaudeSession: Identifiable {
    let id = UUID()
    let claudePID: pid_t
    let terminalApp: TerminalApp
    let terminalPID: pid_t
    let projectPath: String?

    var displayPath: String {
        guard let path = projectPath else { return "Unknown" }
        return path.replacingOccurrences(of: NSHomeDirectory(), with: "~")
    }
}
