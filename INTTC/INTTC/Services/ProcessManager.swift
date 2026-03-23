import Darwin
import Foundation

final class ProcessManager {

    static func killAll(pids: [pid_t]) {
        for pid in pids {
            guard isClaudeProcess(pid) else { continue }
            kill(pid, SIGTERM)
        }
    }

    // Keep resume for crash recovery (in case app crashes while processes were suspended by older version)
    static func resume(pid: pid_t) {
        kill(pid, SIGCONT)
    }

    // MARK: - Private

    private static func isClaudeProcess(_ pid: pid_t) -> Bool {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/bin/ps")
        task.arguments = ["-p", "\(pid)", "-o", "comm="]
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = FileHandle.nullDevice
        do {
            try task.run()
            task.waitUntilExit()
        } catch {
            return false
        }
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""
        return output.trimmingCharacters(in: .whitespacesAndNewlines).hasSuffix("claude")
    }
}
