---
phase: 01
slug: app-shell-and-local-data-backbone
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-03-06
---

# Phase 01 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | XCTest |
| **Config file** | none — Wave 0 installs |
| **Quick run command** | `xcodebuild test -scheme PomodoroMac -destination 'platform=macOS'` |
| **Full suite command** | `xcodebuild test -scheme PomodoroMac -destination 'platform=macOS'` |
| **Estimated runtime** | ~60 seconds |

---

## Sampling Rate

- **After every task commit:** Run `xcodebuild test -scheme PomodoroMac -destination 'platform=macOS'`
- **After every plan wave:** Run `xcodebuild test -scheme PomodoroMac -destination 'platform=macOS'`
- **Before `$gsd-verify-work`:** Full suite must be green
- **Max feedback latency:** 60 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 01-01-01 | 01 | 0 | DASH-01, CONF-05 | unit / UI-shell | `xcodebuild test -scheme PomodoroMac -destination 'platform=macOS'` | ❌ W0 | ⬜ pending |
| 01-02-01 | 02 | 0 | CONF-03 | integration | `xcodebuild test -scheme PomodoroMac -destination 'platform=macOS'` | ❌ W0 | ⬜ pending |
| 01-03-01 | 03 | 0 | CONF-04 | integration | `xcodebuild test -scheme PomodoroMac -destination 'platform=macOS'` | ❌ W0 | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `PomodoroMac.xcodeproj` or equivalent app project — native macOS app target with tests enabled
- [ ] `PomodoroMacTests/` — XCTest target for shell and persistence checks
- [ ] Shell navigation tests — default Dashboard route and six sidebar sections
- [ ] Persistence smoke tests — create and reopen the shared model container
- [ ] Bootstrap tests — default settings registration and recoverable store creation path

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Dashboard visual balance on a clean install | DASH-01 | Layout quality and copy tone are subjective | Launch a clean install and confirm the Dashboard feels timer-first, balanced, and calm without fake metrics |
| Sidebar native feel and collapse behavior | CONF-05 | Native desktop feel is easier to judge interactively | Run the app, collapse and reopen the sidebar, and confirm standard macOS behavior with icon + label navigation |
| Offline cold launch | CONF-04 | Best verified in a true no-network environment | Disable network, launch from a cold state, and confirm the app opens directly to Dashboard without remote dependency |
| Recoverable bootstrap failure path | CONF-03 | Failure handling is hard to validate end-to-end only with unit tests | Simulate store creation failure and confirm the app surfaces a recoverable state instead of crashing |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 60s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
