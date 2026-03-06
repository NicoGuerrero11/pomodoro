# Pomodoro Mac

## What This Is

Pomodoro Mac is a native macOS productivity app built with Swift and SwiftUI for personal use in its first version. It combines a configurable Pomodoro timer with integrated task management, progress tracking, history, and visual productivity metrics so the user can see not only how many sessions were completed, but what work actually moved forward during them.

## Core Value

Every Pomodoro session should clearly connect focused time to concrete task progress.

## Requirements

### Validated

(None yet — ship to validate)

### Active

- [ ] User can run a native macOS Pomodoro timer with fixed 4-cycle logic and configurable work, short-break, and long-break durations within defined presets.
- [ ] User can manage prioritized tasks and associate one or more tasks to a Pomodoro session while still being able to run the timer with no tasks selected.
- [ ] User can review dashboard metrics, task metrics, and session history to understand completed Pomodoros, completed tasks, time spent, and recurring productivity patterns.

### Out of Scope

- User accounts or login in v1 — the app is personal and local-first for the initial release.
- Subtasks in v1 — task management should stay simple until the core timer-task loop is validated.
- Variable cycle counts — the Pomodoro structure is fixed at 4 work cycles by product decision.
- Gamification in v1 — deferred to a later version after the core productivity workflow is solid.
- Exporting reports to PDF/CSV or generating textual reports — not requested yet and not necessary for the MVP.
- Online sync or cloud features in v1 — offline local use is the priority and online capabilities are explicitly deferred.

## Context

The project starts greenfield with no existing codebase. The product is for macOS desktop only and must feel native rather than like a packaged web app. The chosen stack is Swift with SwiftUI, with local persistence and offline-first behavior.

The product is intentionally broader than a simple session counter. Task management is central: tasks include title, description, and priority; the system tracks accumulated time and Pomodoro count per task; and completed tasks must automatically feed metrics and history.

The timer must support start, pause, and reset, configurable work and break durations from approved options, discrete notifications, end-of-cycle sound, and a one-minute remaining break warning. Auto-start behavior for breaks and next work cycles must be configurable in settings.

The app should open on a dashboard and use a sidebar with sections for Dashboard, Timer, Tasks, Statistics, History, and Settings. The active timer experience should stay clean and distraction-free, while the analytics areas can be denser and more visual. Menu bar integration is considered important for the app to feel like a real desktop productivity tool.

Known open questions include the exact local database technology, whether any online capabilities belong in v1, whether widgets or live status should exist beyond the menu bar, how to allocate time when a session is linked to multiple tasks, whether report export is worth adding later, and whether task states should evolve beyond pending/completed.

## Constraints

- **Platform**: macOS desktop only — the first release is explicitly native for Mac.
- **Tech stack**: Swift + SwiftUI — already decided and should guide architecture choices.
- **Persistence**: Local database — data must remain available offline and support analytics/history.
- **Connectivity**: Offline-first — the app must work without network access.
- **Authentication**: No login in v1 — personal local usage does not require accounts yet.
- **Timer rules**: Fixed 4 work cycles — cycle count is not user-configurable.
- **Timer options**: Preset durations only — work and break lengths must stay within the defined ranges from the brief.
- **Task model**: No subtasks in v1 — keep task handling focused on core workflow.
- **UX**: Minimal and friendly — timer screens should reduce distractions while analytics can be more visual.

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Build a native macOS app | Product should feel like a true desktop productivity tool, including menu bar integration | — Pending |
| Use Swift and SwiftUI | Stack is already chosen and aligns with native macOS development | — Pending |
| Store data locally and work offline-first | Personal productivity workflows should not depend on connectivity | — Pending |
| Exclude login from v1 | No account system is needed for the first personal-use release | — Pending |
| Keep Pomodoro cycle count fixed at four | The product wants consistency while still allowing duration customization | — Pending |
| Make task management part of the core product | The main differentiator is linking time spent to actual task progress | — Pending |
| Defer gamification to a later version | The MVP should validate the core timer-task-analytics loop first | — Pending |

---
*Last updated: 2026-03-06 after initialization*
