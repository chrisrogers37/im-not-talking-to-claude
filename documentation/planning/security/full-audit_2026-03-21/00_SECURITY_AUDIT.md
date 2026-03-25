# Security Audit — INTTC

**Date:** 2026-03-21
**Scope:** Full codebase — native macOS app (Swift/SwiftUI) + landing page (React/Vite)
**Auditor:** Automated security scan + manual code review

## Findings

| # | Severity | Category | Finding | Location |
|---|----------|----------|---------|----------|
| 1 | MEDIUM | Env hygiene | `.env` not in `.gitignore` — accidental commit risk | `.gitignore` |
| 2 | MEDIUM | Build security | No hardened runtime or entitlements file configured | `project.pbxproj` |
| 3 | LOW | Env hygiene | No `.env.example` documenting required build variables | (missing) |
| 4 | LOW | Process mgmt | `kill(pid, SIGTERM)` on PIDs without validation they are Claude processes | `ProcessManager.swift:7` |
| 5 | LOW | Crash recovery | Recovery file written with default permissions (potentially world-readable) | `INTTCViewModel.swift:163` |

## Clean Categories

- **Dependencies:** 0 vulnerabilities across 114 npm packages
- **Secret detection:** No hardcoded secrets, API keys, or tokens
- **OWASP Top 10:** No innerHTML, eval, exec, SQL injection, path traversal patterns
- **Auth/Authz:** N/A — no authentication, no web backend
- **Transport security:** All URLs use HTTPS; all `target="_blank"` links have `rel="noopener noreferrer"`
- **Exposed endpoints:** N/A — no server-side code

## Remediation Priority

1. **PR 1 (MEDIUM):** Environment & gitignore hygiene — findings #1, #3
2. **PR 2 (MEDIUM):** Hardened runtime & entitlements — finding #2
3. **PR 3 (LOW):** Process & file security hardening — findings #4, #5

## Dependency Matrix

All three PRs are independent — they can be implemented in any order or in parallel.
