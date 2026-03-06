# Architecture Research

**Domain:** Native macOS productivity app with Pomodoro timer, task tracking, and local analytics
**Researched:** 2026-03-06
**Confidence:** HIGH

## Standard Architecture

### System Overview

```text
┌──────────────────────────────────────────────────────────────────────┐
│                           Presentation Layer                        │
├──────────────────────────────────────────────────────────────────────┤
│  SwiftUI App Shell   Sidebar Navigation   Dashboard / Tasks / Stats │
│  Timer Screen        Settings Screens     Menu Bar Extra            │
└───────────────────────────────┬──────────────────────────────────────┘
                                │
┌───────────────────────────────▼──────────────────────────────────────┐
│                        Application Layer                            │
├──────────────────────────────────────────────────────────────────────┤
│  TimerCoordinator   TaskService   SessionRecorder   AnalyticsService│
│  NotificationBridge SettingsService HistoryQueries                  │
└───────────────────────────────┬──────────────────────────────────────┘
                                │
┌───────────────────────────────▼──────────────────────────────────────┐
│                          Domain Layer                               │
├──────────────────────────────────────────────────────────────────────┤
│  PomodoroCycleRules   TaskProgressPolicy   MetricsAggregationRules  │
│  SessionStateMachine  Validation / Mapping                          │
└───────────────────────────────┬──────────────────────────────────────┘
                                │
┌───────────────────────────────▼──────────────────────────────────────┐
│                        Persistence Layer                            │
├──────────────────────────────────────────────────────────────────────┤
│  SwiftData Models   Repository Implementations   UserDefaults Store │
│  Local Query Models  Seed / Migration Support                       │
└──────────────────────────────────────────────────────────────────────┘
```

This should stay a single-process native macOS app. There is no need for distributed services, sync infrastructure, or plugin boundaries in v1. The main separation that matters is keeping SwiftUI views thin, isolating timer behavior from persistence, and making analytics queryable from stored session data instead of hand-maintained counters.

### Recommended Technical Shape

- **UI framework:** SwiftUI for all primary screens.
- **App lifecycle:** SwiftUI `App` entry point with scene composition for the main window and `MenuBarExtra`.
- **Persistence:** SwiftData for tasks, sessions, task-session links, and history records; `UserDefaults` for lightweight preferences such as selected durations and auto-start flags.
- **Notifications:** `UserNotifications` for work/break completion and break-warning alerts.
- **Sound:** `AVFoundation` or AppKit sound playback behind a small `SoundService`.
- **Native bridge points:** Use narrow AppKit wrappers only where SwiftUI is awkward, such as status item fine-tuning, window activation, or notification-related behaviors.

### Component Responsibilities

| Component | Responsibility | Typical Implementation |
|-----------|----------------|------------------------|
| `AppShell` | Owns scenes, dependency wiring, and top-level navigation | SwiftUI `App`, `WindowGroup`, `MenuBarExtra` |
| `TimerCoordinator` | Runs the active Pomodoro cycle, pause/resume/reset logic, and transition rules | `@MainActor` observable object backed by `Clock`/`Task` timing |
| `SessionRecorder` | Commits completed work sessions and break records to storage | Application service using repositories |
| `TaskService` | Creates, updates, prioritizes, completes, and fetches tasks | Service facade over repositories |
| `AnalyticsService` | Produces dashboard/statistics/history projections from persisted sessions | Read-only query service |
| `NotificationBridge` | Schedules and clears local notifications for cycle events | Adapter over `UNUserNotificationCenter` |
| `SettingsService` | Reads and updates user preferences | Wrapper around `UserDefaults` plus app defaults |
| `Repositories` | Encapsulate persistence reads/writes so views do not talk to storage directly | SwiftData-backed repository types |
| `Domain Rules` | Defines four-cycle logic, allowed duration presets, and task time allocation rules | Pure Swift types and policy objects |

## Recommended Project Structure

```text
PomodoroMac/
├── App/
│   ├── PomodoroMacApp.swift          # Entry point and scene registration
│   ├── AppEnvironment.swift          # Dependency container and shared services
│   └── Navigation/
│       └── AppRouter.swift           # Sidebar destinations and deep-link targets
├── Features/
│   ├── Dashboard/
│   ├── Timer/
│   ├── Tasks/
│   ├── Statistics/
│   ├── History/
│   ├── Settings/
│   └── MenuBar/
├── Domain/
│   ├── Models/                       # Task, session, cycle, metric value types
│   ├── Rules/                        # Pomodoro rules and validation logic
│   └── Policies/                     # Task allocation and completion behavior
├── Application/
│   ├── Services/                     # Timer, tasks, analytics, settings
│   ├── Commands/                     # Mutating use cases
│   └── Queries/                      # Read models for dashboard and history
├── Infrastructure/
│   ├── Persistence/
│   │   ├── Models/                   # SwiftData persisted models
│   │   ├── Repositories/
│   │   └── Migrations/
│   ├── Notifications/
│   ├── Sound/
│   └── System/
└── Shared/
    ├── UI/                           # Reusable native controls and styling
    └── Utilities/
```

### Structure Rationale

- **`Features/`:** Organize screens and view models by user workflow, which keeps SwiftUI code local to the feature it serves.
- **`Application/`:** Central place for orchestration logic that coordinates multiple domain concepts and infrastructure dependencies.
- **`Domain/`:** Keeps timer rules and analytics math testable without UI or database concerns.
- **`Infrastructure/`:** Contains framework-specific code that is easiest to swap or isolate later.
- **`Shared/`:** Only for genuinely reused UI or helpers; avoid turning it into a grab bag early.

## Architectural Patterns

### Pattern 1: Feature-Oriented SwiftUI With Thin Views

**What:** Each screen owns its own SwiftUI views and feature-scoped view model, while business actions are delegated to application services.
**When to use:** Everywhere in v1. This is the default.
**Trade-offs:** Slightly more files than an all-in-one MVVM setup, but it prevents view models from becoming the app's hidden domain layer.

### Pattern 2: Service + Repository Split

**What:** Mutating workflows live in services; persistence details live in repositories.
**When to use:** For tasks, session recording, and settings that are more complex than a single direct save.
**Trade-offs:** Adds indirection, but it makes timer logic and analytics testable without a live database.

### Pattern 3: Derived Analytics Instead of Cached Counters

**What:** Treat session/task history as source of truth and derive dashboard metrics from it.
**When to use:** For completed Pomodoros, focus time, streak-like summaries, and recurring productivity patterns.
**Trade-offs:** Queries are slightly heavier, but the model stays correct and avoids drift from manually synced counters. If performance becomes a real problem, add materialized summaries later, not first.

### Pattern 4: Single Active Timer Authority

**What:** The app has exactly one authoritative timer coordinator responsible for active state transitions.
**When to use:** Always. Menu bar, main timer screen, and notifications must reflect the same live session.
**Trade-offs:** Requires careful dependency injection and state observation, but it prevents duplicated timers and inconsistent countdowns.

## Data Flow

### Core Runtime Flow

```text
User Action
    ↓
SwiftUI Feature View
    ↓
Feature View Model
    ↓
Application Service / TimerCoordinator
    ↓
Domain Rules + Repository
    ↓
SwiftData / UserDefaults / Notification Center
    ↓
Published State / Query Refresh
    ↓
SwiftUI View + Menu Bar Extra + Alerts
```

### State Management

```text
TimerCoordinator (single source of truth for active timer)
    ↓
Timer View / Menu Bar View / Dashboard Summary

SwiftData Query Results (source of truth for persisted records)
    ↓
Tasks / History / Statistics features

SettingsService
    ↓
TimerCoordinator + NotificationBridge + Settings UI
```

The app should not introduce Redux-style global state for v1. Native observable objects plus SwiftData queries are sufficient. Use one shared timer state owner and otherwise prefer feature-local state.

### Key Data Flows

1. **Start Pomodoro:** User selects optional tasks and starts a timer; `TimerCoordinator` validates preset durations, creates an in-memory active session, schedules completion notifications, and publishes countdown state to both the main window and menu bar.
2. **Pause / Resume / Reset:** Timer state changes stay in memory only until a work interval completes or is intentionally discarded. Do not persist partial sessions unless the product later asks for interruption analytics.
3. **Complete Work Interval:** `TimerCoordinator` hands a completed work result to `SessionRecorder`, which writes the session, creates task-session link rows, updates task progress metadata, then asks `AnalyticsService` queries to refresh visible summaries.
4. **Break Transition:** Domain rules compute whether the next segment is short break, long break, or next work cycle in the fixed four-cycle loop; `NotificationBridge` schedules the one-minute remaining break alert when applicable.
5. **Task Completion:** Completing a task updates task status immediately; statistics derive completed-task counts and time spent from stored task and session history.
6. **Dashboard / Statistics Rendering:** Views request aggregated read models from `AnalyticsService`, which queries persisted sessions grouped by date, task, and cycle type instead of reading ad hoc counters from multiple places.

## Data Model Boundaries

### Primary Persistent Entities

| Entity | Owns | Notes |
|--------|------|-------|
| `Task` | Title, description, priority, status, created/completed timestamps | Keep status simple in v1: pending or completed |
| `PomodoroSession` | Start/end time, type, duration, completion state, cycle index | Core history source of truth |
| `TaskSessionLink` | Relationship between a completed work session and one or more tasks | Needed because sessions may be linked to multiple tasks |
| `DailySummary` | Optional future optimization only | Do not build first unless analytics queries prove slow |
| `AppSettings` | Preset selections and auto-start preferences | Prefer `UserDefaults`, not SwiftData |

### Time Allocation Policy

The open product question is how to allocate one work session across multiple tasks. For v1, the most pragmatic policy is equal split across linked tasks for analytics while also preserving the raw session duration. This keeps the model honest, avoids fake precision, and lets the policy evolve later without rewriting the session source data.

## Integration Points

### External/System Services

| Service | Integration Pattern | Notes |
|---------|---------------------|-------|
| `UserNotifications` | Adapter service invoked by timer transitions | Request permission lazily but early enough for a usable first run |
| `MenuBarExtra` | Shared observable state from `TimerCoordinator` | Keep actions minimal: open app, pause/resume, show remaining time |
| `UserDefaults` | Typed settings wrapper | Suitable for preferences, not historical data |
| `SwiftData` | Repository-backed persistence | Good native default for a local-first single-user app |
| `AVFoundation` / AppKit sound | Small sound abstraction | Prevent direct media framework calls from views |

### Internal Boundaries

| Boundary | Communication | Notes |
|----------|---------------|-------|
| `Features ↔ Application` | Direct method calls on injected services | Straightforward and testable for a local app |
| `Application ↔ Domain` | Pure Swift types and policies | Domain should not know about SwiftUI or storage |
| `Application ↔ Infrastructure` | Protocol-driven adapters where behavior touches system frameworks | Keep mocking simple for tests |
| `Timer ↔ Analytics` | Persist completed sessions, then re-query | Avoid live metric mutation during countdown |

## Build-Order Implications

### Recommended Build Sequence

1. **Domain rules first:** Implement Pomodoro cycle rules, preset validation, session/task entities, and multi-task allocation policy in pure Swift. This stabilizes the app's core behavior before UI work spreads assumptions.
2. **Persistence second:** Stand up SwiftData schema, repositories, and sample seed data for tasks and sessions. Analytics and history screens depend on this foundation.
3. **Timer coordinator third:** Build the single active timer engine plus settings integration, pause/resume/reset behavior, and notification scheduling. This is the highest-risk runtime component and should be proven early.
4. **Primary features fourth:** Build Timer and Tasks screens first, then Dashboard, History, and Statistics once real persisted session data exists.
5. **Menu bar and polish last:** Add `MenuBarExtra`, sound, onboarding permission prompts, and UI refinements after the timer state model is stable.

### Dependency Implications

- **Statistics should not be built before session persistence exists.** Otherwise the team will invent temporary counters that become legacy baggage.
- **Menu bar integration should read shared timer state, not create its own timing logic.** This prevents desynchronization between the app window and status item.
- **Settings should be modeled early enough to shape timer behavior, but stored simply.** Do not block core timer work on a complex settings architecture.
- **Notifications should be wired through the timer service boundary, not called from views.** UI-triggered notifications become difficult to reason about once pause/resume and auto-start enter the picture.

## Anti-Patterns

### Anti-Pattern 1: Letting SwiftUI Views Own Timer Logic

**What people do:** Start timers directly inside views with ad hoc `Timer` publishers or duplicated countdown code.
**Why it's wrong:** Background behavior, menu bar state, notifications, and persistence quickly diverge.
**Do this instead:** Keep one authoritative `TimerCoordinator` and let views observe it.

### Anti-Pattern 2: Mixing Preferences and Historical Data

**What people do:** Store everything in `UserDefaults` because it is quick to wire up.
**Why it's wrong:** Queries, filtering, and analytics become fragile and expensive immediately.
**Do this instead:** Use `UserDefaults` only for lightweight settings and SwiftData for tasks and session history.

### Anti-Pattern 3: Precomputing Every Metric on Write

**What people do:** Update many counters every time a session completes.
**Why it's wrong:** Counter drift and migration pain show up fast once task edits and multi-task sessions exist.
**Do this instead:** Persist clean session records and derive metrics through query services.

### Anti-Pattern 4: Over-abstracting for Future Sync

**What people do:** Design the whole app like a cloud product before local-first behavior is proven.
**Why it's wrong:** The MVP becomes slower to build and harder to understand without solving a real v1 problem.
**Do this instead:** Keep architecture local and modular, with only enough boundary discipline to add sync later if the product earns it.

## Scaling Considerations

| Scale | Architecture Adjustments |
|-------|--------------------------|
| Single user on one Mac | Current design is sufficient; one process, local database, derived analytics |
| Large personal history dataset | Add targeted indexes, pagination, and optional precomputed daily summaries |
| Future sync / multi-device | Introduce sync adapters and conflict policy at repository boundaries, not inside feature views |

### Scaling Priorities

1. **First bottleneck:** Statistics queries over long history windows. Fix with better query shaping and optional summary tables.
2. **Second bottleneck:** Timer lifecycle edge cases around sleep/wake, app relaunch, and notification permissions. Fix by hardening `TimerCoordinator` and recovery rules before widening scope.

## Recommended Architecture Decision

For v1, build a layered native macOS app with SwiftUI at the edge, one shared timer coordinator for active runtime state, SwiftData as the local history/task store, and derived analytics generated from persisted sessions. This is the most pragmatic path because it keeps the app feeling native, keeps the implementation small enough for a greenfield product, and avoids premature complexity while still preserving clear seams for later growth.

## Sources

- Apple platform conventions for SwiftUI app lifecycle and scene composition
- Apple local persistence patterns for SwiftData and lightweight preferences
- Apple local notification framework usage for desktop alerts
- Native macOS menu bar integration patterns

---
*Architecture research for: Pomodoro Mac*
*Researched: 2026-03-06*
