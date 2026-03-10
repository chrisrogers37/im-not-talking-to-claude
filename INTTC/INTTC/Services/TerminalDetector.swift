import AppKit

final class TerminalDetector {

    static func runningTerminals() -> [(TerminalApp, NSRunningApplication)] {
        let workspace = NSWorkspace.shared
        var results: [(TerminalApp, NSRunningApplication)] = []

        for terminal in TerminalApp.allCases {
            let apps = workspace.runningApplications.filter {
                $0.bundleIdentifier == terminal.rawValue
            }
            for app in apps {
                results.append((terminal, app))
            }
        }

        return results
    }

    static func terminalPIDs() -> Set<pid_t> {
        Set(runningTerminals().map { $0.1.processIdentifier })
    }
}
