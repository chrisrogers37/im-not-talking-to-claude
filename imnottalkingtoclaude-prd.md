# Babe, I'm Not Talking To Claude — Product Requirements Document

**Version:** 0.1.0 (Draft)
**Author:** Chris
**Date:** March 9, 2026
**Status:** Pre-development

---

## Overview

"Babe, I'm Not Talking To Claude" is a free, open-source macOS menubar utility that lets developers hide and restore all terminal windows running Claude Code with a single click. It's the panic button for when someone walks up to your desk, the wind-down switch at the end of the workday, and the "I swear I wrote this myself" alibi generator.

**Full name:** Babe, I'm Not Talking To Claude
**Short name / process name:** INTTC
**Tagline:** The alibi your git history can't provide.

**Domain:** imnottalkingtoclaude.com (the "Babe," lives in the app and landing page copy, not the domain — keeps the URL clean and typeable while the full phrase carries the comedic timing)

**Positioning:** Every developer using Claude Code has the same ritual: close the lid, leave the terminals open, come back tomorrow and `claude --continue`. This app turns that into a single menubar toggle — hide everything Claude-related, or bring it all back exactly where you left it. The name is a denial — the thing you say when someone catches you mid-conversation with your AI pair programmer.

---

## Problem Statement

Developers using Claude Code in terminal emulators face several daily friction points:

1. **The "someone's behind me" problem.** Claude Code runs in full-screen terminals with visible conversation history. There's no quick way to hide all Claude windows simultaneously without closing them.

2. **The "end of day" problem.** Winding down means manually closing or hiding 3-7 terminal tabs/windows across multiple terminal emulators, then manually reopening and resuming each session the next morning.

3. **The "context switching" problem.** Moving between "pair programming with Claude" mode and "presenting my screen" mode requires manually managing window visibility.

4. **The "resume" problem.** Claude Code supports `claude --continue` (most recent conversation) and `claude --resume` (pick from recent), but remembering which terminals were active and in which directories is manual overhead.

There is no existing tool that provides one-click hide/restore of Claude Code terminal sessions.

---

## Solution

A macOS menubar app with two states:

- **Exposed** (default): All Claude Code terminal windows are visible and running normally.
- **Hidden**: All Claude Code terminal windows are hidden. Optionally, Claude processes are suspended (SIGSTOP) to free resources.

Toggling from Hidden → Exposed restores all previously-hidden terminal windows to their original positions and sizes. If process suspension was enabled, processes are resumed (SIGCONT).

### Detection Strategy

The app detects Claude Code sessions by:

1. Enumerating all running processes matching the `claude` binary.
2. Walking the process tree upward to find the parent terminal emulator process (Terminal.app, iTerm2, Warp, Kitty, Alacritty, Ghostty).
3. Mapping those terminal processes to their corresponding windows via Accessibility APIs (AXUIElement).
4. Tracking which windows contain Claude sessions for targeted hide/restore.

### Hide/Restore Mechanics

**Window-level (default):**
- Uses macOS Accessibility API to set `AXMinimized` or manipulate window visibility on targeted terminal windows.
- Stores window positions, sizes, and z-order before hiding.
- Restores exact window state on unhide.
- Terminal processes continue running — Claude sessions stay alive.

**Process-level (opt-in):**
- In addition to window hiding, sends `SIGSTOP` to Claude Code processes to suspend them.
- Sends `SIGCONT` on restore to resume.
- Reduces CPU/memory usage while hidden.
- Trade-off: suspended processes can't receive notifications or complete background work.

---

## Target Users

**Primary:** Developers who use Claude Code daily in terminal emulators and want a fast way to hide/show their AI pair programming sessions.

**Secondary:** Anyone who presents their screen frequently (demos, pair programming, meetings) and wants to quickly hide Claude conversations.

**Persona:** A developer with 4 terminal windows open — two running Claude Code in different project directories, one with a regular shell, one with `npm run dev`. They want to hide just the Claude windows before a screen share, then bring them back after.

---

## Platform & Compatibility

- **macOS versions:** Ventura (13.0) and later
- **Terminal emulators (v0.1):**
  - Terminal.app
  - iTerm2
  - Warp
  - Kitty
  - Alacritty
  - Ghostty
- **Privileges:** Requires Accessibility permissions (System Settings → Privacy & Security → Accessibility)
- **Distribution:** Direct download (.dmg), GitHub releases, Homebrew cask

---

## Feature Specification

### F1: Master Toggle — Hide/Expose Claude

The primary interaction. A single toggle in the menubar that hides or reveals all detected Claude Code terminal windows.

**Behavior:**
- **Expose → Hidden:** Enumerate all terminal windows with Claude processes. Store their window state (position, size, space/desktop, z-order). Hide those windows. Update menubar icon to "hidden" state.
- **Hidden → Exposed:** Restore all previously-hidden windows to their exact prior state. Update menubar icon to "exposed" state.

**Edge cases:**
- If a terminal window has both Claude and non-Claude tabs, hide the entire window (we can't hide individual tabs in most terminals).
- If a Claude process exits while hidden, remove it from the restore list. Don't restore dead windows.
- If a new Claude process starts while in "hidden" mode, don't auto-hide it — only hide on explicit toggle.

### F2: Process Suspension (Opt-in)

An optional setting that, when enabled, also sends SIGSTOP/SIGCONT to Claude Code processes during hide/restore.

**Default:** Off (window-level only).

**Why opt-in:** Some users may have long-running Claude tasks they don't want interrupted. Process suspension should be a conscious choice.

### F3: Session Catalog

A small dropdown section showing currently detected Claude sessions:

```
┌─────────────────────────────────────┐
│  ~/projects/benzo (iTerm2)      ● │
│  ~/projects/shuffify (Warp)     ● │
│  ~/dotfiles (Terminal.app)      ● │
└─────────────────────────────────────┘
```

Each row shows:
- Working directory of the Claude session
- Terminal emulator name
- Status indicator (running / suspended / hidden)

This builds trust that the app correctly detected all sessions.

### F4: Menubar Icon & Status

A persistent menubar icon with two states:

- **Exposed:** An open eye icon or speech bubble — "Claude is visible"
- **Hidden:** A closed eye or "shh" gesture — "Claude is hidden"

The icon should be distinct and immediately readable at menubar size (18×18 pt).

### F5: Keyboard Shortcut

A global hotkey to toggle hide/expose without clicking the menubar. Default: `⌘⇧H` (Cmd+Shift+H) or user-configurable.

This is critical for the "someone just walked up" use case — the user needs to react in under a second.

### F6: Launch at Login

Option to start the app at login so it's always available in the menubar.

### F7: Scan Interval / Auto-detect

The app should periodically scan for new Claude processes (every 5-10 seconds) so the session catalog stays current. This should be lightweight — just checking the process table, not doing window enumeration until a toggle is triggered.

---

## Features Explicitly Out of Scope (v0.1)

- Auto-resume Claude sessions (launching `claude --continue` in restored terminals)
- Per-session hide/show (hiding individual Claude windows instead of all-or-nothing)
- Integration with Claude.ai browser tabs (only terminal Claude Code)
- Cross-app hiding (VS Code integrated terminals, etc.)
- Windows or Linux support
- Analytics or session time tracking
- "Fake screen" overlay (showing a fake terminal with innocent content)

### Nice-to-haves for v0.2+

- Per-session toggle (hide specific Claude windows from the catalog)
- `claude --continue` auto-launch on restore (re-attach to last conversation)
- VS Code integrated terminal support via extension
- "Boss mode" — replace Claude windows with a decoy terminal showing `npm install` output
- Desktop/Space-aware restore (restore windows to correct virtual desktop)
- Notification when new Claude session detected

---

## Technical Architecture

### Language & Framework

- **Swift** with **SwiftUI** for the menubar popover UI
- **NSStatusItem** for menubar presence
- **Accessibility API** (AXUIElement) for window detection and manipulation
- **Foundation Process** for process table enumeration
- **SMAppService** for launch-at-login

### Terminal Detection Matrix

| Terminal | Bundle ID | Process Name | Window API | Tab Detection |
|---|---|---|---|---|
| Terminal.app | com.apple.Terminal | Terminal | AXUIElement | AppleScript |
| iTerm2 | com.googlecode.iterm2 | iTerm2 | AXUIElement + AppleScript | AppleScript |
| Warp | dev.warp.Warp-Stable | Warp | AXUIElement | Limited |
| Kitty | net.kovidgoyal.kitty | kitty | AXUIElement | Remote control protocol |
| Alacritty | org.alacritty | alacritty | AXUIElement | N/A (single window) |
| Ghostty | com.mitchellh.ghostty | ghostty | AXUIElement | TBD |

### Claude Detection

Detecting Claude Code processes:

```bash
# Find all claude processes
pgrep -fl claude

# Get parent PID to find terminal emulator
ps -o ppid= -p <claude_pid>

# Walk up process tree to find terminal app
```

The app should look for:
- Process name matching `claude` (the Claude Code CLI binary)
- Verify it's actually Claude Code (not another `claude` binary) by checking the executable path

### Window State Model

```swift
struct TrackedWindow {
    let windowRef: AXUIElement        // Accessibility reference
    let terminalBundleID: String      // Which terminal app
    let claudePID: pid_t              // Claude process ID
    let workingDirectory: String      // cwd of the Claude session
    let originalPosition: CGPoint     // Pre-hide position
    let originalSize: CGSize          // Pre-hide size
    let wasMinimized: Bool            // Was it already minimized?
    let desktopNumber: Int?           // Virtual desktop / Space
}
```

### Accessibility Permissions

The app requires Accessibility access to:
- Enumerate windows of other applications
- Read window titles and positions
- Minimize/restore windows programmatically

On first launch, the app should:
1. Check for existing Accessibility permissions.
2. If not granted, show a setup screen explaining why the permission is needed.
3. Open System Settings → Privacy & Security → Accessibility with a deep link.
4. Poll for permission grant and proceed once authorized.

### Key Technical Risks

1. **Accessibility API reliability:** AXUIElement can be flaky with some terminal emulators, especially Electron-based ones (Warp). Need per-terminal testing.

2. **Process tree walking:** Claude Code may be launched via shell scripts, `nvm`, `mise`, or other wrappers that add intermediate processes. The PID walk needs to handle arbitrary depth.

3. **Multiple terminal instances:** A user might have 3 iTerm2 windows but only 1 has Claude. Must identify the correct window, not just the app.

4. **Window restoration across Spaces:** macOS virtual desktops make window restoration complex. v0.1 may restore to the current space and defer cross-space restore to v0.2.

5. **Ghostty support:** Ghostty is relatively new and its Accessibility API surface may have gaps. Needs early testing.

---

## UI/UX Design

### Visual Direction: Caught Red-Handed

The design language is "mid-denial" — the humor of being caught talking to AI and immediately lying about it. The "Babe," sets the entire tone: defensive, caught, slightly panicked, committed to the bit. Think: spy movie aesthetics meets developer tooling meets relationship comedy. Clean, fast, slightly mischievous.

**Color palette:**

| Token | Value | Usage |
|---|---|---|
| Background | #0d1117 | Dark mode primary (GitHub dark) |
| Surface | #161b22 | Cards, dropdowns |
| Text | #e6edf3 | Primary text |
| Text Muted | #7d8590 | Secondary text |
| Text Faint | #484f58 | Tertiary text |
| Exposed (danger) | #f85149 | "You're exposed" state — red/warm |
| Hidden (safe) | #3fb950 | "You're hidden" state — green/safe |
| Accent | #58a6ff | Links, interactive elements |
| Border | rgba(240,246,252,0.1) | Subtle borders |

The "exposed = red, hidden = green" color coding creates an instant emotional response — red means "Claude is showing," green means "you're safe."

### Typography

- **Monospace-forward:** The audience is developers. Lean into terminal aesthetics.
- **Font stack:** JetBrains Mono → SF Mono → monospace for UI text
- **Display font:** Something with character for the landing page hero (Space Grotesk, Clash Display, or similar)

### Menubar Icon States

**Exposed (Claude visible):**
```
👁 (open eye / speech bubble with "..." )
```

**Hidden (Claude concealed):**
```
🫣 (or a closed eye / "shh" icon)
```

The icon should work as both template (monochrome, adapts to dark/light menubar) and colored (for emphasis).

### Menubar Dropdown Layout

```
┌───────────────────────────────────────┐
│                                       │
│  🫣  Not Talking To Claude     [HIDE] │
│  Babe, never was. Nothing to see.     │
│                                       │
├───────────────────────────────────────┤
│                                       │
│  Sessions                             │
│  ~/projects/benzo       iTerm2    ●  │
│  ~/projects/shuffify    Warp      ●  │
│  ~/dotfiles             Terminal   ●  │
│                                       │
├───────────────────────────────────────┤
│  ☐ Suspend processes when hidden      │
│  ⌘⇧H  Toggle shortcut                │
│                                       │
├───────────────────────────────────────┤
│  v0.1.0          Launch at Login  Quit│
└───────────────────────────────────────┘
```

### Interaction Flow

1. **App launches.** Scans for Claude processes. Menubar icon appears (eye open if Claude found, dimmed if no sessions).
2. **User clicks icon or presses hotkey.** Dropdown appears showing detected sessions.
3. **User clicks "Hide" toggle.** All Claude terminal windows animate out (minimize or hide). Icon changes to "hidden" state. Dropdown subtitle updates.
4. **User clicks "Expose" toggle.** All windows restore to original positions. Icon changes back.

### Micro-copy

The app's personality lives in its micro-copy. The voice is mid-denial — "Babe," sets the tone, and everything else follows from that energy:

- Hidden state: "Babe, I'm not talking to Claude. Never was."
- Exposed state: "Claude is showing. Everyone can see."
- No sessions found: "No Claude sessions detected. Suspiciously clean."
- Process suspension on: "Processes frozen. Claude is on ice."
- Hiding animation: Brief flash of 🫣 in the menubar
- First launch: "Babe, it's just a menubar app. It needs Accessibility permissions."

---

## Distribution Strategy

### Primary: GitHub + Direct Download

- GitHub repository with README featuring the landing page copy
- GitHub Releases with signed `.dmg` files
- MIT license

### Secondary: Homebrew

```
brew install --cask imnottalkingtoclaude
```

Or a shorter tap name:
```
brew install --cask not-talking-to-claude
```

### Landing Page

Single-page site at imnottalkingtoclaude.com (Vercel deployment). Key sections:

1. Hero with "Babe," as a whispered aside above the main "I'm not talking to Claude" headline — the comedic beat that sets the tone
2. Interactive mockup of the menubar dropdown
3. "How it works" — three-step visual (Detect → Hide → Restore)
4. Terminal emulator support grid
5. Download CTA + GitHub link

### Pricing

Free. MIT license. This is a community utility and a branding/marketing play for fun.

---

## Marketing & Discovery

The name IS the marketing. "Babe, I'm Not Talking To Claude" is a complete scene in six words — everyone who uses Claude Code has lived this moment. The domain (imnottalkingtoclaude.com) is inherently shareable — it's the kind of URL developers send to each other in Slack.

**Expected channels:**

1. **Twitter/X dev community** — The screenshot of the menubar app + the domain name will get engagement on its own. The "Babe," in the hero is screenshot gold.
2. **Hacker News** — "Show HN: Babe, I'm Not Talking To Claude — one-click hide/restore for Claude Code terminals"
3. **Reddit** — r/ClaudeAI, r/macapps, r/programming
4. **Dev podcasts/newsletters** — The name makes it inherently mentionable. Hosts love saying funny product names. "Babe, I'm not talking to Claude" is a punchline that delivers itself.
5. **Claude community** — Anthropic's Discord, forums, etc.
6. **Word of mouth** — "What's that app in your menubar?" "Oh, it's called 'Babe, I'm Not Talking To Claude'..."

---

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Accessibility API changes in future macOS | Medium | High | Pin to known versions, test on betas |
| Terminal emulator updates break detection | Medium | Medium | Per-terminal abstraction layer; community PRs for fixes |
| Claude Code changes process naming | Low | High | Monitor Claude Code releases; detection by executable path, not just name |
| Ghostty Accessibility API gaps | Medium | Low | Ghostty is under active development; file issues upstream |
| macOS Spaces/multiple desktops complicate restore | High | Medium | v0.1: restore to current space. v0.2: cross-space restore |
| Users confused by Accessibility permission request | Medium | Low | Clear setup screen with explanation and deep link |

---

## Success Metrics

- GitHub stars (target: 1000+ in first month — the name alone drives curiosity)
- Twitter/X impressions on launch post
- Homebrew install count
- "I use this every day" comments (the real metric)

---

## Development Roadmap

### Phase 1 — MVP (v0.1.0)

Core functionality for personal use.

- Menubar icon with hide/expose toggle
- Claude process detection across all 6 terminal emulators
- Window-level hide/restore with position memory
- Optional process suspension (SIGSTOP/SIGCONT)
- Session catalog showing detected Claude instances
- Global keyboard shortcut
- Launch at login
- Accessibility permission onboarding flow
- Landing page at imnottalkingtoclaude.com

### Phase 2 — Polish (v0.2.0)

Community release prep.

- Per-session hide/show from the catalog
- Cross-Space window restoration
- VS Code integrated terminal detection
- Signed and notarized .dmg
- Homebrew cask formula
- Sparkle auto-updates
- "Boss mode" decoy terminal overlay

### Phase 3 — Power Features (v0.3.0+)

Based on community feedback.

- Auto-resume: launch `claude --continue` in restored terminals
- Session persistence across reboots (remember what was hidden)
- Claude.ai browser tab detection (Safari/Chrome)
- Menubar widget (macOS 14+ interactive widgets)
- Statistics: "You've hidden Claude 847 times this month"

---

## Technical Implementation Notes

### Project Structure

```
INTTC/
├── INTTC.xcodeproj/
├── INTTC/
│   ├── App/
│   │   ├── INTTCApp.swift              # @main entry point
│   │   └── AppDelegate.swift           # NSStatusItem, popover management
│   ├── Models/
│   │   ├── ClaudeSession.swift         # Detected Claude session model
│   │   ├── WindowSnapshot.swift        # Window state for restore
│   │   └── AppState.swift              # Global hide/expose state
│   ├── Services/
│   │   ├── ProcessScanner.swift        # Enumerates claude processes
│   │   ├── WindowManager.swift         # AXUIElement hide/restore
│   │   ├── TerminalDetector.swift      # Maps PIDs to terminal windows
│   │   ├── ProcessSuspender.swift      # SIGSTOP/SIGCONT
│   │   └── HotkeyManager.swift        # Global keyboard shortcut
│   ├── ViewModels/
│   │   └── INTTCViewModel.swift        # State management
│   ├── Views/
│   │   ├── PopoverContentView.swift    # Main dropdown layout
│   │   ├── SessionListView.swift       # Claude session catalog
│   │   ├── ToggleView.swift            # Master hide/expose toggle
│   │   ├── SetupView.swift             # Accessibility permission onboarding
│   │   └── FooterView.swift            # Version, settings, quit
│   ├── Theme/
│   │   └── INTTCTheme.swift            # Colors, fonts
│   └── Resources/
│       ├── Assets.xcassets/            # App icon, menubar icons
│       └── Info.plist
├── Landing/                            # React/Vite landing page
│   ├── src/
│   │   └── INTTCLanding.jsx
│   ├── index.html
│   └── package.json
└── CLAUDE.md
```

### Key Implementation Patterns

**Process scanning** should use a lightweight timer (every 5-10s) that calls:
```swift
func scanForClaudeSessions() -> [ClaudeSession] {
    // 1. Get all processes matching "claude"
    // 2. Filter to actual Claude Code binary (check path)
    // 3. Walk process tree up to find terminal emulator PID
    // 4. Return session list with terminal info + working directory
}
```

**Window management** should use AXUIElement:
```swift
func hideWindow(_ ref: AXUIElement) -> WindowSnapshot {
    // 1. Read current position, size, minimized state
    // 2. Store in WindowSnapshot
    // 3. Set AXMinimized = true (or use setAlpha/move offscreen)
    // 4. Return snapshot for later restore
}

func restoreWindow(_ snapshot: WindowSnapshot) {
    // 1. Set AXMinimized = false
    // 2. Set AXPosition to snapshot.position
    // 3. Set AXSize to snapshot.size
    // 4. Optionally raise to front
}
```

**Hotkey registration** should use `CGEvent.tapCreate` or the modern `NSEvent.addGlobalMonitorForEvents` approach, with a user-configurable key combination stored in UserDefaults.

### Bundle ID & Naming

- **Bundle ID:** `com.imnottalkingtoclaude.app`
- **App name in menubar:** Shows only the icon (no text)
- **App name in Finder/Dock:** "Babe, I'm Not Talking To Claude"
- **Process name:** `INTTC`

---

## Appendix: Name Selection

The full name "Babe, I'm Not Talking To Claude" was chosen for maximum humor and shareability. The "Babe," prefix transforms it from a product statement into a scene — you can hear the tone of voice, the defensive denial, the caught-red-handed energy. It immediately sets up the comedic premise without any explanation needed.

The domain remains imnottalkingtoclaude.com (without "Babe") because "babe" in a URL would feel awkward and limit the audience. The domain stays clean and typeable; the "Babe," lives in the app copy and landing page hero where the comedic timing lands properly.

Alternatives considered:

- **NBINTTC** — Acronym of "No Babe I'm Not Talking To Claude." Unpronounceable and hard to type.
- **nobabe.app** — Short but loses the full comedic effect. Also potentially gendered.
- **notclaude.app** — Clear but not funny enough. Sounds like a Claude competitor.
- **Claude Hider** — Descriptive but boring. No personality.
- **AltTab** — Already taken (popular Mac window switcher).
- **Panic Button** — Too generic. Doesn't communicate what it hides.

"Babe, I'm Not Talking To Claude" wins because:
1. It's a complete scene — a denial you'd actually say, mid-conversation, to someone standing behind you.
2. The "Babe," adds comedic timing that a flat statement doesn't have. It implies a relationship, a history of this happening, a pattern.
3. The domain (imnottalkingtoclaude.com) is absurdly long, which is the secondary joke.
4. It's immediately understood by anyone who uses Claude.
5. It's screenshot-worthy — people will share it just for the name.
6. It makes every developer who sees it think "I need this."

---

## Appendix: Comparison with Benzo

Both apps share the same architectural pattern (macOS menubar utility, Swift/SwiftUI, NSStatusItem) but solve different problems:

| | Benzo | Babe, I'm Not Talking To Claude |
|---|---|---|
| Problem | USB battery drain during sleep | Hiding Claude Code terminals |
| System interaction | `pmset` (power management) | Accessibility API (window management) |
| Privileges | sudo / sudoers rule | Accessibility permission |
| Toggle behavior | Enable/disable sleep settings | Hide/restore terminal windows |
| Process interaction | None | Optional SIGSTOP/SIGCONT |
| Detection | N/A | Process scanning + window enumeration |
| Branding | Pharmaceutical/clinical | Mid-denial / developer humor |

The codebase structure is intentionally similar to Benzo for ease of development and maintenance. The AppDelegate, popover pattern, theme system, and view hierarchy follow the same conventions.
