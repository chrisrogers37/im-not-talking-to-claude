# CLAUDE.md — INTTC ("Babe, I'm Not Talking To Claude")

This file provides project-specific guidance for Claude Code. Update this file whenever Claude does something incorrectly so it learns not to repeat mistakes.

---

## Workflow Orchestration

### Plan Mode Default
- Enter plan mode for ANY non-trivial task (3+ steps or architectural decisions)
- If something goes sideways, STOP and re-plan immediately
- Use plan mode for verification steps, not just building
- Write detailed specs upfront to reduce ambiguity

### Subagent Strategy
- Use subagents liberally to keep main context window clean
- Offload research, exploration, and parallel analysis to subagents
- One task per subagent for focused execution

### Verification Before Done
- Never mark a task complete without proving it works
- Diff behavior between main and your changes when relevant
- Run the build, check the app launches, verify the feature works
- Ask yourself: "Would a staff engineer approve this?"

### Autonomous Bug Fixing
- When given a bug report: just fix it. Don't ask for hand-holding
- Go fix failing CI tests without being told how

### Core Principles
- **Simplicity First**: Make every change as simple as possible
- **No Laziness**: Find root causes. No temporary fixes. Senior developer standards.
- **Minimal Impact**: Changes should only touch what's necessary
- **Demand Elegance** (Balanced):
  - For non-trivial changes: pause and ask "is there a more elegant way?"
  - If a fix feels hacky: "Knowing everything I know now, implement the elegant solution"
  - Skip this for simple, obvious fixes — don't over-engineer
  - Challenge your own work before presenting it

---

## Project Overview

**INTTC** is a macOS menubar utility that hides and restores all terminal windows running Claude Code with a single click. A "panic button" for developers — one click to hide everything, one click to bring it all back.

**Version**: 0.1.0

### Architecture

```
INTTC/INTTC/
├── App/
│   ├── INTTCApp.swift           — SwiftUI @main entry point
│   └── AppDelegate.swift        — NSStatusItem, popover, Carbon global hotkey, dynamic eye icon
├── Models/
│   ├── TerminalApp.swift        — enum of 6 supported terminal bundle IDs
│   ├── ClaudeSession.swift      — claudePID, terminalPID, terminalApp, projectPath
│   └── AppState.swift           — HiddenState for crash recovery serialization
├── Services/
│   ├── SessionScanner.swift     — pgrep + proc_pidinfo parent tree walking
│   ├── ProcessManager.swift     — SIGTERM for Claude PIDs (verified before kill)
│   └── TerminalDetector.swift   — terminal app detection from running apps
├── ViewModels/
│   └── INTTCViewModel.swift     — state: hide/show, scan timer (5s), crash recovery, quit restores
├── Views/
│   ├── PopoverContentView.swift — main layout: toggle, sessions, settings, footer
│   ├── MasterToggleView.swift   — "Talking To Claude" / "Not Talking To Claude" toggle
│   ├── SessionCatalogView.swift — collapsible list of detected Claude sessions
│   ├── SettingsView.swift       — killOnHide toggle, hotkey display
│   ├── SetupView.swift          — empty stub (Accessibility no longer required)
│   └── FooterView.swift         — launch at login, version, quit
└── Theme/
    └── INTTCTheme.swift         — dark palette: #0d1117 bg, #f85149 red, #3fb950 green

src/INTTCLanding.jsx             — landing page with interactive mockup
scripts/build-dmg.sh             — archive, sign, notarize, and package as DMG
```

### Key Technical Details

- **Detection**: `pgrep -x claude` finds Claude processes; walks parent PID tree via `proc_pidinfo()` to find terminal ancestor
- **Hiding**: `NSRunningApplication.hide()` on terminal apps — native macOS API, **no Accessibility permissions required**
- **Restoring**: `NSRunningApplication.unhide()` — brings terminal apps back
- **Kill on hide** (optional): `SIGTERM` targets Claude PIDs only (verified via `ps` before kill)
- **Crash recovery**: Writes `~/Library/Application Support/INTTC/hidden-windows.json` before hiding; restores terminal visibility on next launch if file exists
- **Global hotkey**: Cmd+Shift+H via Carbon `RegisterEventHotKey` — no Input Monitoring permission required
- **Menubar icon**: Programmatic NSBezierPath — red open eye (exposed) / green closed eye (hidden)
- **Scan timer**: Refreshes session list every 5 seconds on background queue

### Permissions Model

**INTTC requires NO special macOS permissions.** All APIs used are available to any user process:
- `pgrep`, `proc_pidinfo()`, `sysctl()` — standard process enumeration
- `NSRunningApplication.hide()/unhide()` — standard Cocoa API
- Carbon `RegisterEventHotKey` — system-level global hotkey, no permissions needed
- `kill()` for SIGTERM — works on user-owned processes without sudo

The app originally planned to use AXUIElement (Accessibility API) for window manipulation, but the implementation uses the simpler `NSRunningApplication` approach instead. **Do not add Accessibility permission prompts or checks.**

### Supported Terminals

| Terminal | Bundle ID |
|----------|-----------|
| Terminal.app | com.apple.Terminal |
| iTerm2 | com.googlecode.iterm2 |
| Warp | dev.warp.Warp-Stable |
| Kitty | net.kovidgoyal.kitty |
| Alacritty | org.alacritty |
| Ghostty | com.mitchellh.ghostty |

---

## Development Workflow

1. Make changes
2. Build app: `xcodebuild -project INTTC/INTTC.xcodeproj -scheme INTTC -configuration Debug build`
3. Run landing page: `npm run dev`
4. Before creating PR: verify both app build and landing page render correctly

## Commands Reference

```sh
# Native app
xcodebuild -project INTTC/INTTC.xcodeproj -scheme INTTC -configuration Debug build    # Debug build
xcodebuild -project INTTC/INTTC.xcodeproj -scheme INTTC -configuration Release build  # Release build

# Landing page
npm install          # Install dependencies
npm run dev          # Dev server
npm run build        # Production build

# Distribution
./scripts/build-dmg.sh   # Build DMG (set APPLE_ID, APPLE_TEAM_ID, APP_PASSWORD for notarization)
```

## Code Style & Conventions

- SwiftUI for all views, `@ObservedObject`/`@Published` for state
- Dark theme: background #0d1117, red #f85149 (exposed), green #3fb950 (hidden)
- Popover width: 320px fixed
- Monospace font: JetBrains Mono on landing page
- Landing page uses inline React styles, no CSS framework
- New `.swift` files must be registered in `project.pbxproj` in 4 places:
  1. `PBXBuildFile` section
  2. `PBXFileReference` section
  3. `PBXGroup` section (appropriate group: Views, Models, Services, etc.)
  4. `PBXSourcesBuildPhase` section

## Things Claude Should NOT Do

- Don't add Swift files without registering them in `project.pbxproj` (4 sections)
- Don't use minimize — it creates Dock thumbnails. Use `NSRunningApplication.hide()`
- Don't SIGSTOP/SIGTERM terminal PIDs — only target Claude process PIDs
- Don't add Accessibility permission prompts or AXUIElement code — the app doesn't need them
- Don't skip crash recovery file write before hiding
- Don't change native app UI without updating the landing page mockup

## Project-Specific Patterns

### Process Detection
- `pgrep -x claude` is the reliable entry point — avoids macOS privacy controls
- Parent PID tree walking finds the terminal ancestor: proc_pidinfo (fast) with sysctl fallback
- Working directory extracted via `proc_pidinfo(...PROC_PIDVNODEPATHINFO...)`
- Multiple Claude processes per terminal are deduplicated by terminal PID

### Distribution
- **GitHub Releases** — signed `.dmg`
- Not App Store — uses process APIs incompatible with sandboxing
- Landing page deploys automatically via Vercel on push to `main`

---

## Self-Improvement Loop

After ANY correction from the user:
1. Acknowledge the correction
2. Update `.claude/lessons.md` with the pattern
3. Write rules that prevent the same mistake
4. Review lessons at session start for this project

## Task Management

1. **Plan First**: Write plan to `.claude/todo.md` with checkable items
2. **Verify Plan**: Check in before starting implementation
3. **Track Progress**: Mark items complete as you go
4. **Explain Changes**: High-level summary at each step
5. **Document Results**: Add review section to `.claude/todo.md`
6. **Capture Lessons**: Update `.claude/lessons.md` after corrections

---

_Update this file continuously. Every mistake Claude makes is a learning opportunity._
_After corrections, also update `.claude/lessons.md`._
