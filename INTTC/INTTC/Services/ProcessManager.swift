import Darwin

final class ProcessManager {

    static func suspend(pid: pid_t) {
        kill(pid, SIGSTOP)
    }

    static func resume(pid: pid_t) {
        kill(pid, SIGCONT)
    }

    static func suspendAll(pids: [pid_t]) {
        for pid in pids {
            suspend(pid: pid)
        }
    }

    static func resumeAll(pids: [pid_t]) {
        for pid in pids {
            resume(pid: pid)
        }
    }
}
