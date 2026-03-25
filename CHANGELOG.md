# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/).

## [0.1.0] — 2026-03-21

### Added
- Initial release — macOS menubar utility to hide/restore Claude Code terminal sessions
- One-click hide/show for all terminals running Claude Code
- Global hotkey: Cmd+Shift+H
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
