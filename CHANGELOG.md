# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/).

## [Unreleased]

## [0.2.0] — 2026-03-28

### Fixed
- **Global hotkey** — replaced NSEvent with Carbon `RegisterEventHotKey` (no Input Monitoring permission needed)
- **Landing page URLs** — corrected GitHub repository links
- **Landing page copy** — removed false "Requires Accessibility permission" claim, updated "Suspend processes" to "Kill Claude processes on hide"
- **Landing page domain** — removed reference to nonexistent imnottalkingtoclaude.com

### Added
- **Mobile responsive layout** — grids collapse, padding adapts at <768px breakpoint
- **Vercel deployment** — landing page now live at im-not-talking-to-claude.vercel.app

### Changed
- **Text contrast** — bumped muted/faint colors for WCAG AA compliance
- **CTA button** — improved border visibility and "View on GitHub" link contrast

## [0.1.0] — 2026-03-21

### Added
- Initial release — macOS menubar utility to hide/restore Claude Code terminal sessions
- One-click hide/show for all terminals running Claude Code
- Global hotkey: Cmd+Shift+H (Carbon API — works without Input Monitoring permission)
- Session detection for 6 terminals: Terminal.app, iTerm2, Warp, Kitty, Alacritty, Ghostty
- Collapsible session catalog showing detected Claude sessions
- Optional "Kill on Hide" — sends SIGTERM to Claude processes when hiding
- Crash recovery — restores hidden terminals on next launch
- Launch at Login support
- Dynamic menubar icon: red open eye (exposed) / green closed eye (hidden)
- React/Vite landing page with interactive mockup
- DMG build script with code signing and notarization support

### Security
- PID validation before SIGTERM (verify process is actually Claude)
- Recovery file written with restricted permissions (0o600)
- Added .env to .gitignore with .env.example template

### Removed
- Dead Accessibility API code (WindowManager.swift) — app uses NSRunningApplication.hide() which requires no special permissions
