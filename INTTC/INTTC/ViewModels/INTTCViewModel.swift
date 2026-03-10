import AppKit
import Foundation
import ServiceManagement

final class INTTCViewModel: ObservableObject {
    @Published var isHidden: Bool = false
    @Published var sessions: [ClaudeSession] = []
    @Published var launchAtLogin: Bool = false {
        didSet {
            guard isInitialized else { return }
            updateLaunchAtLogin()
        }
    }
    @Published var needsSetup: Bool = false
    @Published var suspendProcesses: Bool {
        didSet { UserDefaults.standard.set(suspendProcesses, forKey: "suspendProcesses") }
    }
    @Published var errorMessage: String?

    var onStateChange: ((Bool) -> Void)?
    private var isInitialized = false
    private var scanTimer: Timer?
    private var hiddenSnapshots: [WindowSnapshot] = []
    private var hiddenClaudePIDs: [pid_t] = []

    private static let appSupportDir: URL = {
        let dir = FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("INTTC")
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }()

    private static var recoveryFileURL: URL {
        appSupportDir.appendingPathComponent("hidden-windows.json")
    }

    init() {
        self.suspendProcesses = UserDefaults.standard.bool(forKey: "suspendProcesses")
        self.needsSetup = !WindowManager.checkAccessibilityPermission()

        if #available(macOS 13.0, *) {
            self.launchAtLogin = SMAppService.mainApp.status == .enabled
        }

        self.isInitialized = true
        startScanning()
    }

    // MARK: - Session Scanning

    func startScanning() {
        refreshSessions()
        scanTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.refreshSessions()
        }
    }

    func refreshSessions() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let found = SessionScanner.findClaudeSessions()
            DispatchQueue.main.async {
                self?.sessions = found
            }
        }
    }

    // MARK: - Master Toggle

    func toggleMaster() {
        if isHidden {
            showAll()
        } else {
            hideAll()
        }
    }

    private func hideAll() {
        guard !sessions.isEmpty else { return }
        guard WindowManager.checkAccessibilityPermission() else {
            needsSetup = true
            return
        }

        var snapshots: [WindowSnapshot] = []
        var claudePIDs: [pid_t] = []

        // Group sessions by terminal PID to avoid duplicate work
        let terminalPIDs = Set(sessions.map(\.terminalPID))

        for terminalPID in terminalPIDs {
            guard let session = sessions.first(where: { $0.terminalPID == terminalPID }) else {
                continue
            }
            let windows = WindowManager.windowsForApp(pid: terminalPID)

            for window in windows {
                if let snapshot = WindowManager.snapshotWindow(
                    window, bundleID: session.terminalApp.rawValue
                ) {
                    snapshots.append(snapshot)
                    WindowManager.hideWindow(window)
                }
            }
        }

        // Collect Claude PIDs for optional suspension
        claudePIDs = sessions.map(\.claudePID)

        if suspendProcesses {
            ProcessManager.suspendAll(pids: claudePIDs)
        }

        hiddenSnapshots = snapshots
        hiddenClaudePIDs = claudePIDs
        isHidden = true
        onStateChange?(true)

        saveCrashRecovery()
    }

    private func showAll() {
        // Resume processes first
        if suspendProcesses {
            ProcessManager.resumeAll(pids: hiddenClaudePIDs)
        }

        // Restore windows by finding offscreen windows in each terminal app
        for bundleID in Set(hiddenSnapshots.map(\.bundleID)) {
            let apps = NSWorkspace.shared.runningApplications.filter {
                $0.bundleIdentifier == bundleID
            }
            for app in apps {
                let windows = WindowManager.windowsForApp(pid: app.processIdentifier)
                var remaining = hiddenSnapshots.filter { $0.bundleID == bundleID }

                for window in windows {
                    guard let pos = WindowManager.getWindowPosition(window),
                          pos.x < -10000 else { continue }

                    // Match by window title
                    let title = WindowManager.getWindowTitle(window)
                    if let idx = remaining.firstIndex(where: { $0.windowTitle == title }) {
                        WindowManager.restoreWindow(window, to: remaining[idx])
                        remaining.remove(at: idx)
                    } else if let first = remaining.first {
                        // Fallback: restore to any remaining snapshot position
                        WindowManager.restoreWindow(window, to: first)
                        remaining.removeFirst()
                    }
                }
            }
        }

        hiddenSnapshots = []
        hiddenClaudePIDs = []
        isHidden = false
        onStateChange?(false)

        clearCrashRecovery()
    }

    // MARK: - Crash Recovery

    func performCrashRecovery() {
        guard FileManager.default.fileExists(atPath: Self.recoveryFileURL.path) else { return }

        do {
            let data = try Data(contentsOf: Self.recoveryFileURL)
            let state = try JSONDecoder().decode(HiddenWindowsState.self, from: data)

            for snapshot in state.snapshots {
                let apps = NSWorkspace.shared.runningApplications.filter {
                    $0.bundleIdentifier == snapshot.bundleID
                }
                for app in apps {
                    let windows = WindowManager.windowsForApp(pid: app.processIdentifier)
                    for window in windows {
                        if let pos = WindowManager.getWindowPosition(window), pos.x < -10000 {
                            WindowManager.restoreWindow(window, to: snapshot)
                        }
                    }
                }
            }

            clearCrashRecovery()
        } catch {
            clearCrashRecovery()
        }
    }

    func restoreBeforeQuit() {
        if isHidden {
            showAll()
        }
    }

    // MARK: - Setup

    func checkAccessibility() -> Bool {
        let granted = WindowManager.checkAccessibilityPermission()
        needsSetup = !granted
        return granted
    }

    func requestAccessibility() {
        WindowManager.requestAccessibilityPermission()
    }

    func quit() {
        restoreBeforeQuit()
        NSApplication.shared.terminate(nil)
    }

    // MARK: - Private

    private func saveCrashRecovery() {
        let state = HiddenWindowsState(snapshots: hiddenSnapshots, hiddenAt: Date())
        do {
            let data = try JSONEncoder().encode(state)
            try data.write(to: Self.recoveryFileURL)
        } catch {
            // Non-fatal
        }
    }

    private func clearCrashRecovery() {
        try? FileManager.default.removeItem(at: Self.recoveryFileURL)
    }

    private func updateLaunchAtLogin() {
        if #available(macOS 13.0, *) {
            do {
                if launchAtLogin {
                    try SMAppService.mainApp.register()
                } else {
                    try SMAppService.mainApp.unregister()
                }
            } catch {
                errorMessage = "Failed to update launch at login: \(error.localizedDescription)"
            }
        }
    }
}
