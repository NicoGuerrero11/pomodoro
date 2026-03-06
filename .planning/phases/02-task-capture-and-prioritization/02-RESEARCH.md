# Phase 2: Task Capture and Prioritization - Research

**Researched:** 2026-03-06
**Domain:** Native macOS task creation, editing, and priority-first pending task management
**Confidence:** HIGH

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions
- The Tasks section should deliver the first real task management experience inside the existing macOS shell.
- Task creation and editing should happen in-shell, not in a separate modal-first flow.
- The Tasks section should use a master-detail workspace that feels native on macOS.
- Selecting a task should open it directly in editable form.
- The form should expose title, description, and priority immediately.
- Save behavior should be explicit with Save/Cancel rather than autosave.
- Task rows should be compact, show title + priority + short description preview, and remain easy to scan.
- A toolbar action should create additional tasks once the list exists.
- The empty Tasks state should use a focused empty pane with short/direct copy.
- The empty-state CTA and the dashboard CTA should both open a blank task form immediately.

### Claude's Discretion
- Exact visual styling of priority indicators.
- Exact spacing, typography, and toolbar wording.
- Exact native implementation shape for the master-detail workspace as long as the chosen interaction model remains intact.

### Deferred Ideas (OUT OF SCOPE)
- Task completion workflows.
- Task-to-session linking.
- Filters, tags, subtasks, or richer workflow organization.
</user_constraints>

<research_summary>
## Summary

Phase 2 should capitalize on the Phase 1 foundation rather than create a second app architecture inside the Tasks section. The project already has a persisted `TaskItem` domain model, a `TaskRecord` SwiftData backing record, a `TaskRepository`, a shared `AppEnvironment`, and a real Tasks route inside the main shell. That means the phase does not need new persistence technology or a separate view-state pattern just to ship create/edit/order behavior. The main planning job is to turn those seams into a concrete feature flow with clear validation rules and a desktop-native interaction model.

The strongest product fit is a master-detail task workspace scoped to the existing Tasks section: a pending-task list on one side, a form/editor on the other, and blank-form creation routed directly from both the Tasks empty state and the Dashboard CTA. This matches the user’s context decisions, keeps the experience Mac-native, and avoids context-switching into extra windows or sheets for the app’s first task-management pass.

The highest planning risk is not layout but consistency between data rules and UI behavior. Phase 2 is responsible for ordering pending tasks by priority, but later phases own completion, attribution, and metrics. Plans should therefore keep this phase tightly scoped to pending-task CRUD plus deterministic priority ordering, without leaking in completed-task views, analytics logic, or task-session selection. Validation should focus on repository correctness, ordering guarantees, empty-state entry flow, and explicit create/edit save behavior.

**Primary recommendation:** Split Phase 2 into two plans: first harden the task-domain/query rules and test ordering/validation behavior, then ship the Tasks workspace UI that consumes those rules through the shared app environment.
</research_summary>

<standard_stack>
## Standard Stack

### Core
| Library / Framework | Purpose | Why Standard Here |
|---------------------|---------|-------------------|
| SwiftUI | Tasks workspace, editor, toolbar, empty states | Already established in Phase 1 and best fit for native macOS UI continuity. |
| SwiftData via repository boundary | Persisted task CRUD and ordering queries | Already present and sufficient for this phase’s storage needs. |
| Observation | Feature-local UI state where needed | Matches the Phase 1 app shell direction. |
| XCTest | Repository and feature behavior verification | Existing project test stack and fast enough for per-task validation. |

### Existing Reuse
| Existing Asset | Reuse Strategy |
|----------------|----------------|
| `TaskItem` / `TaskRecord` | Extend only as needed for Phase 2 validation and ordering behavior. |
| `TaskRepository` | Keep the single write/query seam for create/edit/list operations. |
| `AppEnvironment` | Inject the repository into the Tasks feature rather than constructing persistence in views. |
| `AppShellView` and router | Replace the Tasks placeholder with the real workspace and deep-link from the dashboard CTA. |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| In-shell master-detail workspace | Sheet-based creation and editing | Faster to stub, but weaker fit for the locked Phase 2 interaction model. |
| Repository-backed ordering queries | Sorting directly in the UI layer | Simpler initially, but makes correctness and tests weaker as task behavior grows. |
| Explicit save/cancel | Autosave drafts | Less friction, but conflicts with the user’s chosen interaction model and raises accidental-edit risk. |
</standard_stack>

<architecture_patterns>
## Architecture Patterns

### Pattern 1: Tasks Feature Stays Inside the Existing Shell
**What:** Replace the current Tasks placeholder with a feature view that lives under the existing `AppSection.tasks` route.
**Why:** Phase 1 already established the shell, routing, and dashboard handoff. Reusing them preserves consistency and avoids introducing a competing navigation pattern.

Planner guidance:
- Keep the Tasks feature inside the existing app window and sidebar contract.
- The dashboard CTA should switch the selected section to `.tasks` and land in task creation immediately.
- Avoid introducing a separate Settings-style window or a modal-only task workflow.

### Pattern 2: Repository-Owned Task Rules
**What:** Put create/edit/list ordering guarantees behind the task repository layer.
**Why:** `TASK-03` is a data rule as much as a UI requirement. Repository-backed ordering gives deterministic behavior and straightforward tests.

Planner guidance:
- Add any needed query methods to `TaskRepositoryType` for pending tasks in priority-first order.
- Keep create/update validation centralized enough that UI code is not responsible for preserving task integrity.
- Preserve future compatibility with completed-task behavior by keeping this phase focused on pending tasks.

### Pattern 3: Master-Detail Task Workspace
**What:** Represent the Tasks section as a list + detail/editor workspace.
**Why:** This is the clearest match to the user’s locked macOS interaction model and scales better than swapping between list and form views.

Planner guidance:
- Keep the list compact and scanable.
- Treat row selection as an editing handoff, not just a passive preview.
- Use a focused empty state before the first task exists, but once tasks exist, maintain the list/editor structure consistently.

### Pattern 4: Explicit Form Lifecycle
**What:** Create and edit flows use explicit Save and Cancel actions with all core fields visible immediately.
**Why:** The context rules out autosave and progressive field reveal. The planner should therefore model draft state clearly and test the difference between saving and discarding.

Planner guidance:
- Distinguish unsaved draft state from persisted task state.
- Ensure switching between tasks cannot silently commit unintended changes.
- Keep the initial form lightweight even though all core fields are visible.

### Anti-Patterns to Avoid
- **UI-owned sorting:** Do not depend on ad hoc view-layer sorting for the canonical priority order.
- **Modal-first creation:** Do not replace the chosen in-shell editor with sheets as the primary workflow.
- **Completion creep:** Do not pull task completion or archive/history UI into this phase.
- **Placeholder carryover:** Do not leave the Tasks section half-placeholder and half-feature; Phase 2 should make it truly usable.
</architecture_patterns>

<common_pitfalls>
## Common Pitfalls

### Pitfall 1: Priority Exists in Data but Not in the Experience
**What goes wrong:** Tasks technically sort correctly, but rows make priority too subtle for users to notice.
**Planning response:** Require visible priority affordances in row rendering and verify order in tests.

### Pitfall 2: Create and Edit Are Two Different UX Systems
**What goes wrong:** New tasks use one surface while existing tasks edit somewhere else, making the feature feel inconsistent.
**Planning response:** Keep a single editor pattern that handles both creation and editing.

### Pitfall 3: Explicit Save Without Draft Handling
**What goes wrong:** Save/Cancel exists visually, but selection changes or navigation can still mutate persisted data unexpectedly.
**Planning response:** Make draft lifecycle a first-class planning concern and test cancel/discard behavior.

### Pitfall 4: Empty State Does Not Connect to the Real Workflow
**What goes wrong:** The empty Tasks view explains the feature but does not actually get the user into a ready-to-type task form.
**Planning response:** Treat the empty-state CTA and dashboard CTA as real entry points, not just navigation affordances.

### Pitfall 5: Pending Ordering Becomes Unclear Once the UI Is Built
**What goes wrong:** The repository may sort correctly, but the visual grouping/density makes ordering feel arbitrary.
**Planning response:** Keep rows compact, keep the list single-purpose, and avoid extra grouping that competes with priority-first ordering in the first release.
</common_pitfalls>

## Planning Implications

### Recommended Phase Split

**Plan 02-01: Task rules and persistence-facing feature seam**
- Add or refine repository APIs for pending-task CRUD and priority-first queries.
- Define validation behavior for title/description/priority input.
- Add tests proving creation, editing, and ordering behavior at the repository/service boundary.
- Ensure dashboard-to-task creation routing has a stable entry seam in app state.

**Plan 02-02: Tasks workspace UI**
- Replace the Tasks placeholder with the real master-detail feature view.
- Implement the toolbar create action, focused empty state, and blank-form entry flow.
- Wire selection-to-edit behavior and explicit Save/Cancel.
- Verify the list shows title + priority + short description preview and reflects priority-first ordering.

### Planner-Facing Risks

| Risk | Why It Matters | Planning Response |
|------|----------------|------------------|
| Validation rules are too vague | Create/edit quality will drift across UI and persistence | Make validation explicit in Plan 02-01. |
| Draft state leaks into persisted state | Explicit save/cancel becomes unreliable | Plan separate draft handling and cancel verification. |
| Dashboard CTA is forgotten | First-task onboarding becomes inconsistent | Include dashboard-to-task creation routing explicitly in Plan 02-02. |
| Priority ordering is only visually implied | Requirement `TASK-03` becomes hard to prove | Put ordering into query tests and UI verification. |

## Validation Architecture

Phase 2 should build directly on the existing XCTest stack and keep feedback loops short. Both plans should be executable with the same `xcodebuild test` command, with repository tests covering ordering/data behavior and feature tests covering task-workspace state transitions where practical.

### Recommended Test Infrastructure

| Property | Recommendation |
|----------|----------------|
| Framework | XCTest |
| Quick run command | `xcodebuild test -scheme PomodoroMac -destination 'platform=macOS'` |
| Full suite command | `xcodebuild test -scheme PomodoroMac -destination 'platform=macOS'` |
| Estimated runtime target | Under 60 seconds |

### What to Validate in Phase 2

| Area | Verification Type | Notes |
|------|-------------------|-------|
| Task creation persists required fields | Automated repository/service test | Covers `TASK-01`. |
| Task editing updates persisted fields cleanly | Automated repository/service test | Covers `TASK-02`. |
| Pending tasks are returned in priority-first order | Automated repository/service test | Covers `TASK-03`. |
| Empty Tasks state opens a blank editor | Automated feature-state test or narrow UI logic test | Important onboarding handoff. |
| Dashboard CTA routes into task creation | Automated feature-state test where possible, otherwise manual | Ensures the first-task flow is real. |
| Save/Cancel behavior respects explicit persistence | Automated feature-state test | Protects the locked interaction model. |

### Suggested Wave 0 Validation Tasks

- Extend the existing XCTest target with task-focused repository tests.
- Add feature tests around task-workspace state if the implementation introduces a dedicated Tasks feature model.
- Keep commands non-watch and fast enough for per-task execution feedback.

### Manual-Only Behaviors

| Behavior | Requirement / Goal | Why Manual |
|----------|--------------------|------------|
| Master-detail feel on desktop | Phase context | Native desktop ergonomics are best judged interactively. |
| Visual clarity of priority indicators | `TASK-03` experience | Readability and emphasis are partially subjective. |
| Overall first-task flow from Dashboard to Tasks | Phase context | Worth confirming in a live app even if state transitions are unit-tested. |

<sources>
## Sources

### Project Artifacts
- `.planning/REQUIREMENTS.md`
- `.planning/STATE.md`
- `.planning/phases/02-task-capture-and-prioritization/02-CONTEXT.md`
- `.planning/phases/01-app-shell-and-local-data-backbone/01-RESEARCH.md`
- `PomodoroMac/Domain/Models/TaskItem.swift`
- `PomodoroMac/Infrastructure/Persistence/Repositories/TaskRepository.swift`
- `PomodoroMac/App/AppEnvironment.swift`
- `PomodoroMac/App/Shell/AppShellView.swift`
- `PomodoroMac/Features/Dashboard/DashboardView.swift`
</sources>

<metadata>
## Metadata

**Research scope:**
- Core technology: SwiftUI task workspace, repository-backed task CRUD, priority ordering
- Ecosystem: Existing Apple-first stack already in the repo
- Validation target: XCTest-backed task and feature-state coverage

**Open questions left to planning discretion:**
- Exact visual styling of priority markers
- Exact nested layout implementation for the master-detail workspace
- Whether a dedicated feature model is needed between repository and view
</metadata>
