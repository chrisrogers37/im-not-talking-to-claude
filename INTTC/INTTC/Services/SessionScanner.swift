import AppKit
import Darwin

final class SessionScanner {

    static func findClaudeSessions() -> [ClaudeSession] {
        let claudePIDs = findClaudePIDs()
        var sessions: [ClaudeSession] = []
        var seenShellPIDs: Set<pid_t> = []

        for pid in claudePIDs {
            // Deduplicate: Claude spawns multiple processes per session
            // sharing the same parent shell — keep only one per shell
            if let parentPID = getParentPID(pid) {
                if seenShellPIDs.contains(parentPID) { continue }
                seenShellPIDs.insert(parentPID)
            }

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
        // Use pgrep for reliable detection — proc_name/proc_pidpath are
        // restricted by macOS privacy controls and return empty for Claude
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/pgrep")
        task.arguments = ["-x", "claude"]
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = FileHandle.nullDevice

        do {
            try task.run()
            task.waitUntilExit()
        } catch {
            return []
        }

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""
        return output.split(separator: "\n").compactMap { pid_t($0) }
    }

    // MARK: - Process Tree Walking

    private static func getParentPID(_ pid: pid_t) -> pid_t? {
        // Try proc_pidinfo first (fast)
        var info = proc_bsdinfo()
        let size = proc_pidinfo(
            pid, PROC_PIDTBSDINFO, 0, &info,
            Int32(MemoryLayout<proc_bsdinfo>.size)
        )
        if size == Int32(MemoryLayout<proc_bsdinfo>.size) {
            return pid_t(info.pbi_ppid)
        }

        // Fallback: sysctl — works for setuid processes like /usr/bin/login
        var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, Int32(pid)]
        var kinfo = kinfo_proc()
        var ksize = MemoryLayout<kinfo_proc>.size
        guard sysctl(&mib, 4, &kinfo, &ksize, nil, 0) == 0 else { return nil }
        return kinfo.kp_eproc.e_ppid
    }

    private static func findTerminalAncestor(for pid: pid_t) -> (TerminalApp, pid_t)? {
        var currentPID = pid
        let runningApps = NSWorkspace.shared.runningApplications

        for _ in 0..<20 {
            guard let parentPID = getParentPID(currentPID) else { return nil }
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
