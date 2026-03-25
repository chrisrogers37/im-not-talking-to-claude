# PR 1: Environment & Gitignore Hygiene

**Status:** :white_check_mark: COMPLETE
**Started:** 2026-03-21
**Completed:** 2026-03-21
**PR:** #3
**Severity:** MEDIUM
**Effort:** Small (< 15 min)
**Findings addressed:** #1, #3

## Files Modified

- `.gitignore`
- `.env.example` (new file)

## Dependencies

None — can be implemented independently.

## Detailed Implementation Plan

### Step 1: Add `.env` to `.gitignore`

**File:** `.gitignore`

Add `.env` and common variants to the gitignore. Currently the file contains:

```
node_modules
dist
.DS_Store
*.xcodeproj/xcuserdata
*.xcodeproj/project.xcworkspace/xcuserdata
DerivedData
INTTC/build
.superpowers/
```

**Add after the last line:**

```
.env
.env.*
!.env.example
```

This ignores all `.env` files but explicitly allows `.env.example` to be tracked.

### Step 2: Create `.env.example`

**File:** `.env.example` (new, at repo root)

Document the environment variables required by `scripts/build-dmg.sh`:

```
# Required for build-dmg.sh (notarization & code signing)
APPLE_ID=your-apple-id@example.com
APPLE_TEAM_ID=YOUR_TEAM_ID
APP_PASSWORD=your-app-specific-password
```

Values must be placeholders only — never real credentials.

## Verification Checklist

- [ ] `git check-ignore .env` returns `.env` (confirming it's ignored)
- [ ] `git check-ignore .env.local` returns `.env.local`
- [ ] `git check-ignore .env.example` returns nothing (it's tracked)
- [ ] `.env.example` contains only placeholder values
- [ ] `scripts/build-dmg.sh` still references the same env var names

## What NOT To Do

- Do not add real Apple credentials to `.env.example`
- Do not use `.env.sample` — `.env.example` is the convention for this repo's toolchain
- Do not add `.env` patterns inside the Xcode-specific gitignore sections — keep them in the general section
