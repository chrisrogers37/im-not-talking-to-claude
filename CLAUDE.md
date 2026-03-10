# INTTC — "Babe, I'm Not Talking To Claude"

macOS menubar utility that hides Claude Code terminal sessions with one click.

## Architecture

- **Native app**: Swift/SwiftUI menubar app at `INTTC/`
- **Landing page**: React/Vite at repo root (`src/`, `index.html`)
- Same repo structure as [Benzo](~/Projects/benzo)

### Native App Structure

```
INTTC/INTTC/
├── App/            — INTTCApp.swift (entry), AppDelegate.swift (menubar + popover + hotkey)
├── Models/         — TerminalApp (6 terminal bundle IDs), ClaudeSession, AppState (WindowSnapshot)
├── Services/       — SessionScanner (proc_listallpids), WindowManager (AXUIElement), ProcessManager (SIGSTOP/SIGCONT), TerminalDetector
├── ViewModels/     — INTTCViewModel (state, scan timer, hide/show, crash recovery)
├── Views/          — PopoverContentView, MasterToggleView, SessionCatalogView, SettingsView, SetupView, FooterView
├── Theme/          — INTTCTheme (dark: #0d1117 bg, #f85149 red, #3fb950 green)
└── Resources/      — Assets.xcassets
```

### Key Technical Details

- **Detection**: `proc_listallpids` + `proc_name`/`proc_pidpath` finds Claude processes, walks parent PID tree to identify terminal ancestor
- **Hiding**: AXUIElement moves windows offscreen (-32000, -32000) — avoids Dock thumbnails from minimize
- **Restoring**: Moves windows back to saved positions from WindowSnapshot
- **Process suspension**: SIGSTOP/SIGCONT targets Claude PIDs specifically (not terminal PIDs)
- **Crash recovery**: Writes `~/Library/Application Support/INTTC/hidden-windows.json` before hiding; restores on next launch if file exists
- **Global hotkey**: Cmd+Shift+H via NSEvent.addGlobalMonitorForEvents + addLocalMonitorForEvents
- **Menubar icon**: Programmatic NSBezierPath — red open eye (exposed) / green closed eye (hidden)
- **V1 conservative matching**: If terminal PID is ancestor of Claude process, hides ALL windows of that terminal app

### Supported Terminals

| Terminal | Bundle ID |
|----------|-----------|
| Terminal.app | com.apple.Terminal |
| iTerm2 | com.googlecode.iterm2 |
| Warp | dev.warp.Warp-Stable |
| Kitty | net.kovidgoyal.kitty |
| Alacritty | org.alacritty |
| Ghostty | com.mitchellh.ghostty |

## Build Commands

### Native App
```bash
xcodebuild -project INTTC/INTTC.xcodeproj -target INTTC build
```

### Landing Page
```bash
npm install
npm run dev      # dev server
npm run build    # production build → dist/
```

### Distribution DMG
```bash
chmod +x scripts/build-dmg.sh
./scripts/build-dmg.sh   # requires APPLE_ID, APPLE_TEAM_ID, APP_PASSWORD env vars
```

## Code Style

- SwiftUI with MVVM pattern (mirrors Benzo)
- Dark theme: background #0d1117, red #f85149 (exposed), green #3fb950 (hidden)
- Popover width: 320px fixed
- Font: system font, sizes 10-15pt
- All new Swift files must be registered in project.pbxproj (PBXBuildFile + PBXFileReference + group membership)

## Things Claude Should NOT Do

1. Do not add files to the Xcode project without updating project.pbxproj
2. Do not use minimize (AXMinimize) — it creates Dock thumbnails
3. Do not SIGSTOP terminal PIDs — only SIGSTOP Claude process PIDs
4. Do not assume window AXUIElement refs persist across app restarts — match by title for crash recovery
5. Do not skip crash recovery file write before hiding windows
