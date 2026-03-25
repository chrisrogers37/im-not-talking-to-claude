# PR 2: Hardened Runtime & Entitlements

**Status:** MANUAL — requires Xcode UI, not automatable from CLI
**Severity:** MEDIUM
**Effort:** Small (< 30 min)
**Findings addressed:** #2

## Files Modified

- `INTTC/INTTC.xcodeproj/project.pbxproj` (build settings)
- `INTTC/INTTC/INTTC.entitlements` (new file)

## Dependencies

None — can be implemented independently.

## Context

The Xcode project has no entitlements file and `ENABLE_HARDENED_RUNTIME` is not set in `project.pbxproj`. This means:

1. **Notarization will fail** — Apple requires hardened runtime for notarized apps since macOS 10.14.5
2. **No runtime protections** — the app lacks code injection protection, DYLD environment variable restrictions, and debugging protection that hardened runtime provides
3. **The build-dmg.sh script** calls `xcrun notarytool submit`, which will reject the app without hardened runtime

## Detailed Implementation Plan

### Step 1: Enable Hardened Runtime in Xcode

This is best done in Xcode UI:

1. Open `INTTC/INTTC.xcodeproj` in Xcode
2. Select the INTTC target → **Signing & Capabilities** tab
3. Click **+ Capability** → add **Hardened Runtime**
4. This auto-creates the entitlements file and sets `ENABLE_HARDENED_RUNTIME = YES` in both Debug and Release build settings

### Step 2: Configure Entitlements

The app needs no special entitlements for its current functionality:

- `NSRunningApplication.hide()/unhide()` — does not require accessibility entitlement
- `proc_pidinfo` / `sysctl` — does not require special entitlements
- `Process()` with `/usr/bin/pgrep` — does not require special entitlements
- `kill(pid, SIGTERM/SIGCONT)` — works on processes owned by the same user, no entitlement needed

The entitlements file should be minimal:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict/>
</plist>
```

If the app needs to be debugged during development, Xcode will automatically handle the `com.apple.security.get-task-allow` entitlement for Debug builds.

### Step 3: Verify pbxproj Changes

After enabling in Xcode, confirm `project.pbxproj` contains these in both Debug and Release build settings:

```
ENABLE_HARDENED_RUNTIME = YES;
CODE_SIGN_ENTITLEMENTS = INTTC/INTTC.entitlements;
```

## Verification Checklist

- [ ] `xcodebuild -project INTTC/INTTC.xcodeproj -target INTTC build` succeeds
- [ ] `codesign -d --entitlements :- INTTC/build/Release/INTTC.app` shows the entitlements
- [ ] `codesign -v --strict INTTC/build/Release/INTTC.app` passes validation
- [ ] The entitlements file is registered in `project.pbxproj` (PBXBuildFile + PBXFileReference)
- [ ] `scripts/build-dmg.sh` runs through the archive + notarization steps without rejection

## What NOT To Do

- Do not add `com.apple.security.app-sandbox` — the app needs to send signals to processes and inspect the process table, which sandboxing would block
- Do not add `com.apple.security.automation.apple-events` — the app no longer uses AXUIElement/Apple Events
- Do not manually edit `project.pbxproj` for this change — use Xcode UI to avoid corrupt file references
- Do not forget to register the new `.entitlements` file in the Xcode project (the UI handles this automatically)
