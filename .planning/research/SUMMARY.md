# Project Research Summary

**Project:** Pomodoro Mac
**Domain:** Native macOS productivity app with Pomodoro timer, task tracking, local analytics, and history
**Researched:** 2026-03-06
**Confidence:** HIGH

## Executive Summary

This product fits a well-understood native macOS app pattern: a SwiftUI desktop app with one authoritative timer engine, local persistence, system notifications, menu bar presence, and analytics derived from persisted session history rather than ad hoc counters. The research strongly supports staying Apple-first for v1, keeping the runtime dependency surface minimal, and treating the differentiator as the connection between focus sessions and task progress instead of over-expanding into a full project manager.

The recommended implementation path is to build the core timer rules, persistence model, and task-session attribution semantics before spending effort on visual polish or richer analytics. The highest-risk failures are not cosmetic. They are timer drift, conflicting timer state across surfaces, weak recovery after relaunch or sleep/wake, and misleading metrics caused by ambiguous or mutable history data.

## Key Findings

### Recommended Stack

The recommended v1 stack is `Swift 6.x`, `SwiftUI`, modern observation plus Swift concurrency, `SwiftData` for the initial local store, `UserDefaults` for lightweight preferences, `UserNotifications` for alerts, Apple `Charts` for analytics, and `MenuBarExtra` for menu bar integration. AppKit should remain a narrow escape hatch for status item or window behavior that SwiftUI cannot express cleanly.

This stack matches the product constraints well: macOS-only, native, offline-first, single-user, and analytics-heavy but not yet enterprise-grade. The one caveat is persistence. `SwiftData` is the right starting default, but the app should keep a repository boundary so it can move to direct SQLite or GRDB later if analytics queries or migrations become a bottleneck.

**Core technologies:**
- `SwiftUI`: primary app UI and scene composition — best native fit for a greenfield macOS app.
- `SwiftData`: tasks, sessions, and history persistence — strong default for local-first single-user storage.
- `UserNotifications`: completion alerts and break warnings — required for timer usability away from the main window.
- `Charts`: dashboard and statistics visualizations — first-party charting is sufficient for v1.
- `MenuBarExtra`: native quick access and timer visibility — important to the desktop utility feel of the app.

### Expected Features

Research confirms the brief is already aimed at the correct first-release feature set. Table stakes are a reliable configurable timer, clear controls, local notifications, task management, history, settings, and native navigation/menu bar presence. The differentiators are task-linked sessions, a unified dashboard that connects focus time to completed work, task-level analytics, and pattern analytics by day or time block.

**Must have (table stakes):**
- Reliable Pomodoro timer with fixed 4-cycle flow and configurable approved presets — users will not trust the product without this.
- Flat task management with priority and completion state — the app is explicitly more than a standalone timer.
- Durable local history and core dashboard metrics — necessary to make progress visible.
- Notifications, sounds, and settings-backed auto-start options — expected behavior in a desktop timer.

**Should have (competitive):**
- Task-linked sessions that feed both history and task progress — this is the main product differentiator.
- Unified dashboard tying together sessions, completed tasks, and focus time — answers “what moved forward?”
- Menu bar quick visibility and control — strengthens the native desktop workflow.

**Defer (v2+):**
- Gamification — interesting later, but not part of validating the core loop.
- Cloud sync, accounts, or online collaboration — conflicts with the local-first MVP.
- Subtasks, projects, exports, and complex workflow states — expand scope faster than the product needs.

### Architecture Approach

The app should be a single-process native macOS application with thin SwiftUI views over a small application layer and a pure domain layer for timer and analytics rules. The most important architectural choice is to maintain one shared timer authority that every surface observes, while history and metrics derive from persisted session events rather than UI state.

**Major components:**
1. `TimerCoordinator` — owns the active timer, cycle transitions, and control actions.
2. `TaskService` and `SessionRecorder` — manage tasks and persist completed or interrupted sessions.
3. `AnalyticsService` — derives dashboard, history, and per-task statistics from stored events.
4. `NotificationBridge` and menu bar surface — project shared timer state into system integrations.
5. Persistence layer — stores tasks, sessions, task-session links, and lightweight settings.

### Critical Pitfalls

1. **Timer drift and sleep/wake bugs** — avoid tick-driven truth; derive session state from authoritative timestamps and explicit transitions.
2. **Multiple timer authorities** — keep one shared timer source of truth for main window, menu bar, and notifications.
3. **Late or weak persistence semantics** — persist enough session state to recover cleanly after crash, relaunch, or interruption.
4. **Mutable or ambiguous analytics** — compute metrics from stable session history, not UI counters or mutable task fields.
5. **Undefined multi-task attribution** — choose and record a task-time allocation rule before building per-task metrics.

## Implications for Roadmap

Based on research, suggested phase structure:

### Phase 1: Foundation and Data Model
**Rationale:** Domain rules and persistence must exist before timer correctness or analytics can be trusted.
**Delivers:** Core entities, fixed 4-cycle rules, settings model, local storage, and task/session schema.
**Addresses:** Local persistence, task model, session history.
**Avoids:** Weak crash recovery and ambiguous data semantics.

### Phase 2: Timer Engine and Controls
**Rationale:** The timer is the app’s operational core and highest trust surface.
**Delivers:** Start, pause, reset, skip, auto-start behavior, and cycle transitions on a single timer authority.
**Uses:** Swift concurrency, notifications integration points, domain state machine.
**Implements:** `TimerCoordinator` and core control flows.

### Phase 3: Tasks and Session Attribution
**Rationale:** The differentiator requires connecting sessions to actual work, not just time.
**Delivers:** Task CRUD, priority ordering, completion flow, zero/one/many task linking, attribution policy.
**Uses:** Persistence relationships and domain policies.
**Implements:** `TaskService`, `SessionRecorder`, task-session linkage.

### Phase 4: Dashboard, History, and Statistics
**Rationale:** Visual progress only matters after trustworthy event data exists.
**Delivers:** Dashboard metrics, task metrics, filtered history, and initial charts.
**Uses:** Charts, analytics queries, stored sessions.
**Implements:** `AnalyticsService`, dashboard/history/statistics features.

### Phase 5: Native Integrations and UX Polish
**Rationale:** Menu bar experience and system polish should sit on a stable timer/data foundation.
**Delivers:** Menu bar controls, sounds, notification refinement, dark/light polish, and workflow smoothing.
**Uses:** `MenuBarExtra`, sound service, app lifecycle hooks.
**Implements:** Native Mac experience improvements without changing core semantics.

### Phase Ordering Rationale

- Timer correctness depends on domain rules and persistence, so foundation must precede timer UI.
- Analytics depends on clean task and session history, so dashboards come after timer and attribution semantics.
- Menu bar and other system integrations should observe stable shared state, not pioneer app logic on their own.

### Research Flags

Phases likely needing deeper research during planning:
- **Phase 1:** Persistence choice details and migration strategy if `SwiftData` proves limiting.
- **Phase 5:** Menu bar behavior, lifecycle edge cases, and notification UX nuances on macOS.

Phases with standard patterns (skip research-phase if needed):
- **Phase 2:** Core timer controls and state-machine implementation are straightforward once domain rules are locked.
- **Phase 3:** Flat task management is standard if scope stays limited.

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack | HIGH | Strong fit with current Apple-first macOS app patterns, with a manageable persistence caveat |
| Features | HIGH | Closely aligned with both the user brief and standard product expectations |
| Architecture | HIGH | Clear component boundaries and dependency order emerged consistently |
| Pitfalls | HIGH | Risks are domain-specific and directly actionable in planning |

**Overall confidence:** HIGH

### Gaps to Address

- **Local database choice depth:** Start with `SwiftData`, but confirm during Phase 1 planning whether analytics and migrations justify a lower-level store.
- **Task-time attribution rule:** Decide the exact v1 rule during planning so metrics stay interpretable from day one.
- **Widget or live status surface:** Keep out of the initial roadmap unless menu bar access proves insufficient.

## Sources

### Primary (HIGH confidence)
- https://developer.apple.com/documentation/swiftui/menubarextra — menu bar scene support for native macOS apps
- https://developer.apple.com/documentation/usernotifications/asking-permission-to-use-notifications — notification authorization model
- https://developer.apple.com/documentation/usernotifications/scheduling-a-notification-locally-from-your-app — local notification scheduling patterns
- https://developer.apple.com/documentation/swiftdata/modelcontainer — SwiftData storage container behavior
- https://developer.apple.com/documentation/swiftui/migrating-from-the-observable-object-protocol-to-the-observable-macro — modern observation guidance

### Secondary (MEDIUM confidence)
- `.planning/research/STACK.md` — stack recommendation for this project
- `.planning/research/FEATURES.md` — expected feature landscape and launch scope
- `.planning/research/ARCHITECTURE.md` — proposed native macOS architecture
- `.planning/research/PITFALLS.md` — domain-specific failure modes and prevention strategies

---
*Research completed: 2026-03-06*
*Ready for roadmap: yes*
