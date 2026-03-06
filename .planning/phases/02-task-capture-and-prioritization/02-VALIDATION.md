---
phase: 02
slug: task-capture-and-prioritization
status: draft
nyquist_compliant: true
wave_0_complete: false
created: 2026-03-06
---

# Phase 02 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | XCTest |
| **Config file** | none — existing Swift package + XCTest target |
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
| 02-01-01 | 01 | 1 | TASK-01 | repository / unit | `xcodebuild test -scheme PomodoroMac -destination 'platform=macOS'` | ❌ W0 | ⬜ pending |
| 02-01-02 | 01 | 1 | TASK-02 | repository / unit | `xcodebuild test -scheme PomodoroMac -destination 'platform=macOS'` | ❌ W0 | ⬜ pending |
| 02-01-03 | 01 | 1 | TASK-03 | repository / unit | `xcodebuild test -scheme PomodoroMac -destination 'platform=macOS'` | ❌ W0 | ⬜ pending |
| 02-02-01 | 02 | 2 | TASK-01, TASK-02 | feature-state / integration | `xcodebuild test -scheme PomodoroMac -destination 'platform=macOS'` | ❌ W0 | ⬜ pending |
| 02-02-02 | 02 | 2 | TASK-03 | feature-state / integration | `xcodebuild test -scheme PomodoroMac -destination 'platform=macOS'` | ❌ W0 | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `PomodoroMacTests/Tasks/TaskRepositoryTests.swift` — creation, editing, and priority-order assertions
- [ ] `PomodoroMacTests/Tasks/TasksWorkspaceTests.swift` or equivalent — empty-state and explicit save/cancel flow coverage
- [ ] Task-workspace hooks in app state or feature model — if needed to test dashboard-to-task creation routing deterministically

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Master-detail task workspace feels native on macOS | Phase context | Desktop ergonomics and column balance are subjective | Launch Tasks, create/edit several items, and confirm the list/detail arrangement feels natural in the existing app shell |
| Priority indicators are visually clear without clutter | TASK-03 | Emphasis/readability is partly visual judgment | Verify that higher-priority items stand out enough to explain ordering at a glance |
| Dashboard CTA makes first-task creation feel immediate | TASK-01 | End-to-end feel is better judged interactively | From Dashboard, use Create First Task and confirm the blank form is ready for typing in Tasks |

---

## Validation Sign-Off

- [x] All tasks have `<automated>` verify or Wave 0 dependencies
- [x] Sampling continuity: no 3 consecutive tasks without automated verify
- [x] Wave 0 covers all MISSING references
- [x] No watch-mode flags
- [x] Feedback latency < 60s
- [x] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
