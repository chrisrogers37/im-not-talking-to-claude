import AppKit
import Darwin

final class SessionScanner {

    static func findClaudeSessions() -> [ClaudeSession] {
        let claudePIDs = findClaudePIDs()
        var sessions: [ClaudeSession] = []

        for pid in claudePIDs {
            if let (terminalApp, terminalPID) = findTerminalAncestor(for: pid) {
                let projectPath = getWorkingDirectory(for: pid)
                sessions.append(ClaudeSession(
                    claudePID: pid,
                    terminalApp: terminalApp,
                    terminalPID: terminalPID,
                    projectPath: projectPath
                ))
            }
        }

        return sessions
    }

    // MARK: - Process Discovery

    private static func findClaudePIDs() -> [pid_t] {
        let count = proc_listallpids(nil, 0)
        guard count > 0 else { return [] }

        var pids = [pid_t](repeating: 0, count: Int(count) * 2)
        let byteSize = Int32(MemoryLayout<pid_t>.size * pids.count)
        let actualCount = proc_listallpids(&pids, byteSize)
        guard actualCount > 0 else { return [] }

        var claudePIDs: [pid_t] = []

        for i in 0..<Int(actualCount) {
            let pid = pids[i]
            guard pid > 0 else { continue }

            // Check process name
            var nameBuffer = [CChar](repeating: 0, count: Int(MAXCOMLEN) + 1)
            proc_name(pid, &nameBuffer, UInt32(nameBuffer.count))
            let name = String(cString: nameBuffer)

            if name == "claude" {
                claudePIDs.append(pid)
                continue
            }

            // Check executable path for claude
            var pathBuffer = [CChar](repeating: 0, count: Int(MAXPATHLEN))
            let pathLength = proc_pidpath(pid, &pathBuffer, UInt32(MAXPATHLEN))
            if pathLength > 0 {
                let path = String(cString: pathBuffer)
                if path.hasSuffix("/claude") {
                    claudePIDs.append(pid)
                }
            }
        }

        return claudePIDs
    }

    // MARK: - Process Tree Walking

    private static func findTerminalAncestor(for pid: pid_t) -> (TerminalApp, pid_t)? {
        var currentPID = pid
        let runningApps = NSWorkspace.shared.runningApplications

        for _ in 0..<20 {
            var info = proc_bsdinfo()
            let size = proc_pidinfo(
                currentPID,
                PROC_PIDTBSDINFO,
                0,
                &info,
                Int32(MemoryLayout<proc_bsdinfo>.size)
            )
            guard size == Int32(MemoryLayout<proc_bsdinfo>.size) else { return nil }

            let parentPID = pid_t(info.pbi_ppid)
            guard parentPID > 1 else { return nil }

            if let app = runningApps.first(where: { $0.processIdentifier == parentPID }),
               let bundleID = app.bundleIdentifier,
               let terminal = TerminalApp(rawValue: bundleID) {
                return (terminal, parentPID)
            }

            currentPID = parentPID
        }

        return nil
    }

    // MARK: - Working Directory

    private static func getWorkingDirectory(for pid: pid_t) -> String? {
        var vnodeInfo = proc_vnodepathinfo()
        let size = proc_pidinfo(
            pid,
            PROC_PIDVNODEPATHINFO,
            0,
            &vnodeInfo,
            Int32(MemoryLayout<proc_vnodepathinfo>.size)
        )
        guard size == Int32(MemoryLayout<proc_vnodepathinfo>.size) else { return nil }

        let path = withUnsafePointer(to: &vnodeInfo.pvi_cdir.vip_path) { ptr in
            ptr.withMemoryRebound(to: CChar.self, capacity: Int(MAXPATHLEN)) { charPtr in
                String(cString: charPtr)
            }
        }

        return path.isEmpty ? nil : path
    }
}
