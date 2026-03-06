# Phase 2: Task Capture and Prioritization - Context

**Gathered:** 2026-03-06
**Status:** Ready for planning

<domain>
## Phase Boundary

Deliver the first usable Tasks section for the app: users can create tasks, edit tasks, and view pending tasks ordered by priority. This phase defines the day-one task management experience inside the existing macOS shell, not task completion outcomes, task-session linking, filters, or richer workflow features.

</domain>

<decisions>
## Implementation Decisions

### Task editor flow
- Creating a task should stay inside the existing app shell rather than opening a separate modal flow.
- The Tasks section should use a detail-pane editor that fits the Mac-native split-view structure already established in Phase 1.
- Selecting an existing task should open it directly in editable form rather than requiring a second explicit edit mode.
- The form should show all core fields immediately: title, description, and priority.
- Create and edit should use explicit Save and Cancel actions rather than autosave.

### Task list structure
- The Tasks section should feel like a native master-detail workspace: task list on one side, editor/detail on the other.
- Task rows should be compact but not bare: a two-line feel with good scanability.
- Each row should show the title, a visible priority signal, and a short description preview.
- Creating another task after the list already exists should come from a clear toolbar action.

### Empty-state behavior
- The empty Tasks view should use a focused empty pane rather than showing fake list scaffolding.
- Empty-state copy should stay short, calm, and direct, consistent with Phase 1.
- The primary empty-state action should immediately open a blank task editor.
- The Dashboard's "Create First Task" action should jump into the Tasks section with a blank form already open.

### Claude's Discretion
- Exact visual treatment of priority badges/labels, as long as priority remains easy to notice in the list.
- Exact row spacing, typography, and toolbar labeling within the established native macOS style.
- Whether the master-detail Tasks workspace uses nested split view or an equivalent native layout approach, as long as it preserves the chosen interaction model.

</decisions>

<specifics>
## Specific Ideas

- The Tasks section should feel immediately usable for real work, not like a placeholder screen with future-oriented copy.
- The first-task flow should reduce friction: when the user decides to create a task, the form should already be ready for typing.

</specifics>

<code_context>
## Existing Code Insights

### Reusable Assets
- `PomodoroMac/Domain/Models/TaskItem.swift`: Existing domain contract for task title, notes, priority, and persisted state.
- `PomodoroMac/Infrastructure/Persistence/Models/TaskRecord.swift`: Existing SwiftData record already stores the task fields this phase needs.
- `PomodoroMac/Infrastructure/Persistence/Repositories/TaskRepository.swift`: Existing repository seam can back Phase 2 create/edit/list behavior without exposing SwiftData to views.
- `PomodoroMac/App/AppEnvironment.swift`: Task repository is already composed into the shared app environment.
- `PomodoroMac/App/Navigation/AppRouter.swift`: Existing router can support the Dashboard-to-Tasks handoff.

### Established Patterns
- The app uses calm, honest empty states with no sample data.
- The shell is already Mac-native and split-view oriented, so Tasks should extend that pattern rather than inventing a new window or modal-heavy workflow.
- Local-first repository boundaries are already in place, so feature code should stay on domain/repository APIs instead of constructing persistence state directly in views.

### Integration Points
- `PomodoroMac/App/Shell/AppShellView.swift`: The Tasks section currently routes to a placeholder and is the handoff point for real Phase 2 UI.
- `PomodoroMac/Features/Dashboard/DashboardView.swift`: The existing "Create First Task" CTA should route into the new task creation flow.
- `PomodoroMac/Features/Shared/SectionPlaceholderView.swift`: The current Tasks placeholder will be replaced by the real task list/editor workspace.

</code_context>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope.

</deferred>

---
*Phase: 02-task-capture-and-prioritization*
*Context gathered: 2026-03-06*
