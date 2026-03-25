# Lessons Learned — INTTC

## 1. Accessibility permissions are NOT required
The app originally planned to use AXUIElement for window manipulation. The implementation uses `NSRunningApplication.hide()/unhide()` instead, which requires zero permissions. The old `WindowManager.swift` (Accessibility check/prompt) was dead code and has been removed. **Never add Accessibility permission checks back.**

## 2. Don't use minimize — use hide
`NSRunningApplication.hide()` hides the entire app from the screen and Dock. Minimizing individual windows via AXMinimize creates Dock thumbnails, which defeats the purpose of hiding Claude sessions.

## 3. Only SIGTERM Claude PIDs, never terminal PIDs
Killing or stopping the terminal process would close ALL tabs/windows, not just Claude sessions. Only target the specific Claude process PIDs. Always verify PIDs via `ps -p <pid> -o comm=` before sending SIGTERM.

## 4. pbxproj requires 4 sections for new Swift files
Every new `.swift` file must be registered in:
1. PBXBuildFile
2. PBXFileReference
3. PBXGroup (correct parent group)
4. PBXSourcesBuildPhase
Missing any section causes "Cannot find X in scope" build errors.

## 5. Code signing and debug rebuilds
Each Xcode debug rebuild produces a new ad-hoc signature. If any future feature requires macOS permissions tied to code signing (e.g., Accessibility), every rebuild invalidates the permission grant. The current architecture avoids this entirely by not requiring special permissions.

## 6. Crash recovery file must be written BEFORE hiding
If the app crashes while terminals are hidden and no recovery file exists, there's no way to automatically unhide them on next launch. Always write the recovery file before calling `hide()`.

## 7. Landing page mockup must stay in sync with native app
Any UI or behavioral change to the native app must also be reflected in `src/INTTCLanding.jsx`. They must stay in sync.
