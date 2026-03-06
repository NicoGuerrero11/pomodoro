---
phase: 02-task-capture-and-prioritization
plan: 01
subsystem: database
tags: [swiftdata, tasks, repository, xctest]
requires:
  - phase: 01-app-shell-and-local-data-backbone
    provides: local SwiftData repositories, app bootstrap wiring, and test container helpers
provides:
  - explicit task draft validation for create and edit flows
  - deterministic pending-task queries ordered by priority before the UI layer
  - repository tests covering create, edit, validation, and ordering guarantees
affects: [02-02, tasks, app-environment]
tech-stack:
  added: []
  patterns: [repository-owned task drafts, persisted priority sort rank, SwiftData-backed repository tests]
key-files:
  created: [PomodoroMacTests/Tasks/TaskRepositoryTests.swift]
  modified:
    - PomodoroMac/Domain/Models/TaskItem.swift
    - PomodoroMac/Infrastructure/Persistence/Models/TaskRecord.swift
    - PomodoroMac/Infrastructure/Persistence/Repositories/TaskRepository.swift
key-decisions:
  - "Create and edit flows now pass through TaskDraft validation so the UI never persists partial task state directly."
  - "Pending-task ordering is stored as a numeric priority rank and queried from SwiftData with deterministic tie-breakers."
patterns-established:
  - "TaskDraft + repository methods: UI code should create drafts, then call createTask/updateTask instead of constructing persistence logic."
  - "Priority-first task queries live in the repository, with UI consumers treating fetchPending as canonical."
requirements-completed: [TASK-01, TASK-02, TASK-03]
duration: 7min
completed: 2026-03-06
---

# Phase 2 Plan 01: Task rules and persistence seam Summary

**Task drafts with reusable validation, repository-owned create/edit APIs, and deterministic priority-first pending queries backed by SwiftData**

## Performance

- **Duration:** 7 min
- **Started:** 2026-03-06T22:24:54Z
- **Completed:** 2026-03-06T22:31:59Z
- **Tasks:** 3
- **Files modified:** 4

## Accomplishments
- Added `TaskDraft`, `TaskValidationError`, and repository entry points that make create/edit behavior explicit before the Tasks UI is built.
- Persisted a numeric priority sort rank so pending-task ordering stays canonical inside the repository boundary.
- Added repository tests proving task creation, edit-in-place behavior, blank-title rejection, and priority-first pending ordering.

## Task Commits

Each task was committed atomically:

1. **Task 1: Formalize Phase 2 task rules at the domain and repository seam** - `ef41dc5` (feat)
2. **Task 2: Implement repository-backed create, edit, validation, and ordered pending-task queries** - `2c58ea7` (feat)
3. **Task 3: Add repository tests for task creation, editing, validation, and priority order** - `513eb5f` (test)

## Files Created/Modified
- `PomodoroMac/Domain/Models/TaskItem.swift` - Adds task drafts, validation, and task-update helpers for create/edit flows.
- `PomodoroMac/Infrastructure/Persistence/Models/TaskRecord.swift` - Stores a persisted priority sort rank alongside the raw priority value.
- `PomodoroMac/Infrastructure/Persistence/Repositories/TaskRepository.swift` - Exposes explicit create/update/pending APIs and queries pending tasks in deterministic display order.
- `PomodoroMacTests/Tasks/TaskRepositoryTests.swift` - Covers repository create, update, validation, and ordering guarantees with in-memory SwiftData tests.

## Decisions Made
- Validation is enforced at the domain/repository seam through `TaskDraft` so later UI work can share one consistent rule for save eligibility.
- Pending-task ordering uses persisted priority rank, then `createdAt`, then `id`, which keeps equal-priority items predictable without view-layer sorting.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Replaced invalid `xcodebuild` verification with SwiftPM commands**
- **Found during:** Task 1 (Formalize Phase 2 task rules at the domain and repository seam)
- **Issue:** The repo is a Swift package without an `.xcodeproj` or `.xcworkspace`, so the plan's `xcodebuild` commands could not run from this codebase.
- **Fix:** Verified the package with `swift build` and `swift test` instead, which exercise the same source and test targets in the existing project structure.
- **Files modified:** None
- **Verification:** `swift build`, `swift test`
- **Committed in:** N/A (verification workflow adjustment only)

**2. [Rule 3 - Blocking] Ran SwiftPM verification outside the sandbox**
- **Found during:** Task 1 and Task 3
- **Issue:** Sandboxed `swift build` failed because SwiftPM manifest evaluation invoked `sandbox-exec`, which is not permitted in this execution environment.
- **Fix:** Re-ran `swift build` and `swift test` with escalated permissions so package verification could complete normally.
- **Files modified:** None
- **Verification:** `swift build`, `swift test`
- **Committed in:** N/A (environment-only fix)

**3. [Rule 3 - Blocking] Updated planning state files manually after `gsd-tools` parse failure**
- **Found during:** Final state update
- **Issue:** `gsd-tools state advance-plan` could not parse the current `STATE.md` template because it expects `Current Plan` and `Total Plans in Phase` fields that are not present in this repo's state format.
- **Fix:** Updated `STATE.md`, `ROADMAP.md`, and `REQUIREMENTS.md` manually to the same completed-plan end state required by the execution workflow.
- **Files modified:** .planning/STATE.md, .planning/ROADMAP.md, .planning/REQUIREMENTS.md
- **Verification:** Manual file review after patching
- **Committed in:** final metadata commit

---

**Total deviations:** 3 auto-fixed (3 Rule 3 blocking issues)
**Impact on plan:** Verification and planning-file updates were adjusted to match the real package layout, sandbox constraints, and current state template. Product scope and shipped code stayed aligned with the plan.

## Issues Encountered
None

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
The task repository now gives Plan 02-02 a thin feature seam for blank drafts, explicit saves, in-place edits, and canonical pending-task ordering. No known blockers remain for building the Tasks workspace UI on top of this contract.

## Self-Check: PASSED
- Found summary file `.planning/phases/02-task-capture-and-prioritization/02-01-SUMMARY.md`
- Found task commit `ef41dc5`
- Found task commit `2c58ea7`
- Found task commit `513eb5f`
