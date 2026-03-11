import Darwin

final class ProcessManager {

    static func killAll(pids: [pid_t]) {
        for pid in pids {
            kill(pid, SIGTERM)
        }
    }

    // Keep resume for crash recovery (in case app crashes while processes were suspended by older version)
    static func resume(pid: pid_t) {
        kill(pid, SIGCONT)
    }
}
