# PR 3: Process & File Security Hardening

**Status:** :white_check_mark: COMPLETE
**Started:** 2026-03-21
**Completed:** 2026-03-21
**PR:** #4
**Severity:** LOW
**Effort:** Small (< 30 min)
**Findings addressed:** #4, #5

## Files Modified

- `INTTC/INTTC/Services/ProcessManager.swift`
- `INTTC/INTTC/ViewModels/INTTCViewModel.swift`

## Dependencies

None — can be implemented independently.

## Detailed Implementation Plan

### Finding #4: PID Validation in ProcessManager

**File:** `INTTC/INTTC/Services/ProcessManager.swift:5-8`

**Current code:**
```swift
static func killAll(pids: [pid_t]) {
    for pid in pids {
        kill(pid, SIGTERM)
    }
}
```

The PIDs come from `SessionScanner.findClaudeSessions()` which uses `pgrep -x claude`, so they are Claude PIDs at scan time. However, between scan and kill, a PID could be recycled (process exits, new unrelated process gets the same PID). This is a low-probability race condition but worth a defensive check.

**After:**
```swift
static func killAll(pids: [pid_t]) {
    for pid in pids {
        // Verify the process is still a claude process before signaling
        guard isClaudeProcess(pid) else { continue }
        kill(pid, SIGTERM)
    }
}

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
    let output = String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
    return output.trimmingCharacters(in: .whitespacesAndNewlines).hasSuffix("claude")
}
```

This adds a pre-kill check that the PID still belongs to a process named "claude". The race window is narrowed but not eliminated (TOCTOU), which is acceptable for this threat level.

### Finding #5: Restrict Recovery File Permissions

**File:** `INTTC/INTTC/ViewModels/INTTCViewModel.swift:161-163`

**Current code:**
```swift
let data = try JSONEncoder().encode(state)
try data.write(to: Self.recoveryFileURL)
```

`Data.write(to:)` creates files with default permissions (typically 0644 — owner read/write, group/others read). The recovery file contains PIDs and terminal bundle IDs, which is low-sensitivity data, but restricting to owner-only is good practice.

**After:**
```swift
let data = try JSONEncoder().encode(state)
try data.write(to: Self.recoveryFileURL)
// Restrict to owner-only read/write
try FileManager.default.setAttributes(
    [.posixPermissions: 0o600],
    ofItemAtPath: Self.recoveryFileURL.path
)
```

The two-step approach is preferred over `FileManager.createFile` because `createFile` returns `Bool` and doesn't throw — we'd lose error visibility in the existing `do/catch` block.

## Verification Checklist

- [ ] `xcodebuild -project INTTC/INTTC.xcodeproj -target INTTC build` succeeds
- [ ] Launch the app, toggle hide with active Claude sessions, verify terminals hide/show correctly
- [ ] Toggle "Kill Claude on hide" → verify only Claude processes are terminated (check Activity Monitor)
- [ ] After hiding, run `ls -la ~/Library/Application\ Support/INTTC/hidden-windows.json` — permissions should show `-rw-------` (600)
- [ ] Force-quit the app while hidden → relaunch → verify crash recovery restores terminals
- [ ] Verify `ProcessManager.resume(pid:)` still works for crash recovery (SIGCONT path is unchanged)

## What NOT To Do

- Do not add expensive validation (e.g., walking the entire process tree) in the kill path — a simple name check is sufficient
- Do not change the recovery file location — `~/Library/Application Support/INTTC/` is the correct macOS convention
- Do not add file locking for the recovery file — it's only written/read by a single process
- Do not modify the `resume(pid:)` method — SIGCONT on a wrong PID is harmless (it just resumes a process that wasn't stopped)
