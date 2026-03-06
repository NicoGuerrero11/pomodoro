# Feature Research

**Domain:** Native macOS Pomodoro and personal productivity app
**Researched:** 2026-03-06
**Confidence:** HIGH

## Feature Landscape

### Table Stakes (Users Expect These)

Features users will assume exist in a serious Pomodoro app. Missing them makes the app feel incomplete before differentiation matters.

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| Configurable Pomodoro timer with fixed 4-cycle flow | Core product promise; users expect work, short break, and long break timing to be reliable | MEDIUM | Depends on a durable timer state model, background-safe timing, and settings-backed duration presets |
| Start, pause, resume, skip, and reset controls | Timer apps fail immediately if session control is weak | LOW | Keep state transitions explicit; avoid ambiguous "restart from anywhere" behavior in v1 |
| Local notifications and session sounds | A desktop timer must be able to pull the user back without constant focus on the window | MEDIUM | Depends on macOS notification permissions, sound assets, and break warning scheduling |
| Task list with title, notes, priority, and completion state | Task context is central to this product, not an optional side panel | MEDIUM | Keep the data model flat in v1: no subtasks, no projects, no tags required for launch |
| Optional task association for each session | Users need flexibility to run a Pomodoro with or without a selected task | MEDIUM | Requires a session-to-task relationship that allows zero, one, or many linked tasks |
| Persistent history of sessions and completed work | Users expect past sessions and completed tasks to survive app restarts | MEDIUM | Depends on local persistence and immutable session records for analytics correctness |
| Basic analytics dashboard | Without visible progress, this becomes just another timer | MEDIUM | Launch metrics should stay narrow: sessions completed, focused time, completed tasks, recent trends |
| Settings for presets and auto-start behavior | Users expect basic personalization without rebuilding the Pomodoro method | LOW | Should cover approved duration presets, auto-start breaks, and auto-start next focus block |
| Native macOS navigation and menu bar presence | A Mac-only app should feel native and quickly accessible | MEDIUM | Sidebar navigation is table stakes for the full app; menu bar access materially improves desktop utility |

### Differentiators (Competitive Advantage)

These are the features that make the app meaningfully better than a generic Pomodoro timer and align to the core value of connecting focused time to real task progress.

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| Task-linked focus sessions that feed both timer history and task progress | Turns time tracking into visible task advancement instead of isolated session counts | HIGH | Needs a clear attribution rule when multiple tasks are linked to one session; for v1, use equal split or a single primary-task model |
| Unified dashboard connecting sessions, completed tasks, and time spent | Helps the user answer "what moved forward?" instead of only "how long did I focus?" | MEDIUM | Depends on clean event storage and consistent completion semantics in the task model |
| Task-level productivity analytics | Makes the task list smarter over time by showing Pomodoros, minutes, and completion outcomes per task | MEDIUM | Useful once enough history exists; can ship in a light version in v1 if metrics stay simple |
| Pattern analytics by day and time block | Surfaces recurring productivity patterns that influence scheduling decisions | MEDIUM | Depends on timestamped session history; keep visualizations modest in v1 |
| Menu bar quick control with active session visibility | Makes the app feel like a native work companion rather than a dashboard that must stay foregrounded | MEDIUM | Should support current phase, time remaining, and basic control actions without duplicating the full app |

### Anti-Features (Commonly Requested, Often Problematic)

Features that sound attractive but would undermine a disciplined first release.

| Feature | Why Requested | Why Problematic | Alternative |
|---------|---------------|-----------------|-------------|
| Cloud sync and user accounts | Seems necessary for "real" productivity software and future multi-device use | Adds identity, conflict resolution, sync failures, and privacy work before the core loop is validated | Stay local-first in v1 and design storage boundaries so sync can be layered on later |
| Subtasks, projects, boards, and complex workflow states | Users often want a full task manager, not just a focused work companion | Expands the task domain faster than the timer and analytics experience can mature; high UX and schema complexity | Keep a flat task list with pending/completed in v1 |
| Custom cycle designer and arbitrary Pomodoro rules | Power users ask for fully flexible methods | Conflicts with the product decision to keep a fixed 4-cycle flow and weakens product clarity | Support only approved duration presets and fixed long-break cadence |
| Gamification, streaks, and points | Feels motivating and marketable | Easy to ship badly, can distort behavior, and distract from measuring actual work moved forward | Use honest progress metrics tied to tasks and completed sessions |
| Exportable reports and polished PDF/CSV outputs | Attractive for sharing and archival | Adds formatting, support burden, and edge cases before the app has validated which metrics matter | Show in-app history and dashboards first, then export the stabilized metrics later |

## Feature Dependencies

```text
[Local Persistence]
    └──requires by──> [Session History]
                           └──enables──> [Dashboard Metrics]
                                              └──enables──> [Pattern Analytics]

[Task Model]
    └──requires by──> [Task-Linked Sessions]
                           └──enables──> [Task-Level Analytics]

[Timer Engine]
    ├──requires by──> [Session Controls]
    ├──requires by──> [Notifications / Sounds]
    └──requires by──> [Menu Bar Quick Control]

[Settings]
    └──configures──> [Timer Engine]

[Cloud Sync] ──conflicts with v1 simplicity──> [Local-First MVP Scope]
[Complex Task Hierarchies] ──conflicts with──> [Fast v1 Task Capture]
```

### Dependency Notes

- **Session history depends on local persistence:** analytics are only trustworthy if completed sessions are stored durably and consistently.
- **Dashboard metrics depend on session history:** aggregate views should be derived from immutable events, not ad hoc counters.
- **Pattern analytics depend on dashboard-grade data quality:** time-of-day and day-of-week insights are low value if timestamps or completion rules are inconsistent.
- **Task-linked sessions depend on the task model:** the product differentiator breaks down if task identity and completion semantics are unstable.
- **Task-level analytics depend on task-linked sessions:** per-task time and Pomodoro counts should come from session attribution, not manual entry.
- **Notifications, sounds, and menu bar control depend on the timer engine:** these experiences must reflect one authoritative timer state to avoid drift.
- **Settings configure the timer engine:** approved presets and auto-start toggles should flow through the same timer configuration path.
- **Cloud sync conflicts with local-first MVP scope:** it multiplies architecture choices before the core timer-task loop is proven useful.
- **Complex task hierarchies conflict with fast v1 capture:** every added structure makes quick task entry and maintenance slower.

## MVP Definition

### Launch With (v1)

- [ ] Reliable Pomodoro timer with fixed 4-cycle logic, approved duration presets, and start/pause/reset/skip controls
- [ ] Local notifications, end-of-session sound, and one-minute break warning
- [ ] Flat task management with title, notes, priority, pending/completed state
- [ ] Optional linking of zero, one, or more tasks to a session
- [ ] Durable local persistence for tasks, settings, and immutable session history
- [ ] Dashboard with core metrics: completed Pomodoros, focused time, completed tasks, and recent activity
- [ ] History view for prior sessions and task outcomes
- [ ] Native app structure: sidebar navigation plus useful menu bar presence

### Add After Validation (v1.x)

- [ ] Deeper task analytics, including average Pomodoros-to-completion and recent drift in unfinished tasks
- [ ] Richer pattern views by weekday and time block once enough real usage data exists
- [ ] Faster capture and control flows such as global shortcuts or stronger menu bar quick actions
- [ ] More opinionated task attribution rules if multi-task sessions prove common in real use

### Future Consideration (v2+)

- [ ] Optional sync or backup across devices after the local model and conflict strategy are clear
- [ ] Imports/exports once the app's analytics vocabulary has stabilized
- [ ] Broader task organization primitives such as projects or tags if the flat model becomes a proven limit
- [ ] Widgets or additional ambient surfaces beyond the menu bar if they solve real access friction

## Feature Prioritization Matrix

| Feature | User Value | Implementation Cost | Priority |
|---------|------------|---------------------|----------|
| Reliable timer engine and controls | HIGH | MEDIUM | P1 |
| Local persistence and session history | HIGH | MEDIUM | P1 |
| Flat task management | HIGH | MEDIUM | P1 |
| Optional task-to-session linking | HIGH | MEDIUM | P1 |
| Core dashboard metrics | HIGH | MEDIUM | P1 |
| Notifications, sounds, and break warning | HIGH | MEDIUM | P1 |
| Menu bar quick visibility/control | MEDIUM | MEDIUM | P2 |
| Task-level analytics | MEDIUM | MEDIUM | P2 |
| Pattern analytics | MEDIUM | MEDIUM | P2 |
| Complex exports/reporting | LOW | HIGH | P3 |
| Cloud sync/accounts | LOW for v1 | HIGH | P3 |
| Projects/subtasks/workflow depth | LOW for v1 | HIGH | P3 |

**Priority key:**
- P1: Must have for launch
- P2: Should have after the core loop is stable
- P3: Defer until the product proves the need

## First-Release Recommendation

The first release should compete on one clear idea: every completed Pomodoro should map cleanly to either explicit task progress or intentionally unstructured focus time. That means v1 should be narrow but polished around timer reliability, lightweight task capture, trustworthy history, and a dashboard that makes progress legible.

The biggest scope risk is turning the task area into a full project manager. The second biggest is overbuilding analytics before the event model is stable. If the app nails timer reliability, task linkage, and honest progress metrics, it will already be more compelling than a generic Pomodoro timer.

## Sources

- [PROJECT.md](/Users/nicolasguerrero/Projects/personal/pomodoro/.planning/PROJECT.md)
- [FEATURES template](/Users/nicolasguerrero/Projects/personal/pomodoro/.codex/get-shit-done/templates/research-project/FEATURES.md)

---
*Feature research for: Pomodoro Mac*
*Researched: 2026-03-06*
