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
    @Published var killOnHide: Bool = false
    @Published var errorMessage: String?

    var onStateChange: ((Bool) -> Void)?
    private var isInitialized = false
    private var scanTimer: Timer?
    private var hiddenClaudePIDs: [pid_t] = []
    private var hiddenTerminalPIDs: Set<pid_t> = []

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

        let claudePIDs = sessions.map(\.claudePID)
        let terminalPIDs = Set(sessions.map(\.terminalPID))

        // Kill Claude processes if enabled (for sleep/overnight)
        if killOnHide {
            ProcessManager.killAll(pids: claudePIDs)
        }

        // Hide terminal apps using native macOS hide
        for terminalPID in terminalPIDs {
            if let app = NSRunningApplication(processIdentifier: terminalPID) {
                app.hide()
            }
        }

        hiddenClaudePIDs = claudePIDs
        hiddenTerminalPIDs = terminalPIDs
        isHidden = true
        onStateChange?(true)

        saveCrashRecovery()
    }

    private func showAll() {
        // Unhide terminal apps
        for terminalPID in hiddenTerminalPIDs {
            if let app = NSRunningApplication(processIdentifier: terminalPID) {
                app.unhide()
            }
        }

        hiddenClaudePIDs = []
        hiddenTerminalPIDs = []
        isHidden = false
        onStateChange?(false)

        clearCrashRecovery()
    }

    // MARK: - Crash Recovery

    func performCrashRecovery() {
        guard FileManager.default.fileExists(atPath: Self.recoveryFileURL.path) else { return }

        do {
            let data = try Data(contentsOf: Self.recoveryFileURL)
            let state = try JSONDecoder().decode(HiddenState.self, from: data)

            // Unhide any terminal apps that were hidden
            for bundleID in state.terminalBundleIDs {
                let apps = NSWorkspace.shared.runningApplications.filter {
                    $0.bundleIdentifier == bundleID
                }
                for app in apps {
                    app.unhide()
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

    func quit() {
        restoreBeforeQuit()
        NSApplication.shared.terminate(nil)
    }

    // MARK: - Private

    private func saveCrashRecovery() {
        let terminalBundleIDs = sessions.compactMap { session -> String? in
            NSRunningApplication(processIdentifier: session.terminalPID)?.bundleIdentifier
        }
        let state = HiddenState(
            claudePIDs: hiddenClaudePIDs,
            terminalBundleIDs: Array(Set(terminalBundleIDs)),
            hiddenAt: Date()
        )
        do {
            let data = try JSONEncoder().encode(state)
            try data.write(to: Self.recoveryFileURL)
            try FileManager.default.setAttributes(
                [.posixPermissions: 0o600],
                ofItemAtPath: Self.recoveryFileURL.path
            )
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
