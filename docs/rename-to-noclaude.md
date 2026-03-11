# Rename: INTTC → noclaude

## Decision

Rename the short-form / package name from `INTTC` to `noclaude`.

- **Brand name** (unchanged): "Babe, I'm Not Talking To Claude"
- **Short name / abbreviation**: `noclaude`

## Why

- `INTTC` is an opaque acronym — meaningless to anyone who sees it
- `noclaude` immediately communicates what the app does
- Clean in all contexts: `noclaude.app`, `noclaude.pkg`, menubar label

## What Needs to Change

### Files & Directories
- [ ] `INTTC/` → `noclaude/` (Xcode project folder)
- [ ] `INTTC.xcodeproj` → `noclaude.xcodeproj`
- [ ] Rename target, scheme, and product name in Xcode
- [ ] Update `Assets.xcassets` app icon set name if needed

### Code References
- [ ] Bundle identifier: `com.inttc.*` → `com.noclaude.*`
- [ ] `INTTCApp.swift` → `NoclaudeApp.swift` (and `@main` struct name)
- [ ] `INTTCViewModel` → `NoclaudeViewModel`
- [ ] `INTTCTheme` → `NoclaudeTheme`
- [ ] All `INTTC`-prefixed type names throughout Swift files
- [ ] Crash recovery path: `~/Library/Application Support/INTTC/` → `~/Library/Application Support/noclaude/`
- [ ] Update `CLAUDE.md` references

### Distribution
- [ ] DMG filename: `noclaude.dmg`
- [ ] Package name: `noclaude.pkg`
- [ ] Update `scripts/build-dmg.sh`

### Landing Page
- [ ] Update any references in `src/` that use "INTTC" as a display name
- [ ] Keep "Babe, I'm Not Talking To Claude" as the headline/brand

## Notes

- The full brand name "Babe, I'm Not Talking To Claude" stays everywhere user-facing (landing page, About screen, README)
- `noclaude` is just the shorthand for filenames, package IDs, and menubar display
- Consider: Anthropic trademark implications of using "Claude" in the package name (low risk for a small utility, but worth noting)
