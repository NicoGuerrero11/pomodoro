# Stack Research

**Domain:** Native macOS productivity app (Pomodoro, tasks, analytics, history)
**Researched:** 2026-03-06
**Confidence:** HIGH overall, with MEDIUM confidence on the default persistence recommendation for long-term analytics scaling

## Recommendation Summary

Build the app as a native macOS application with SwiftUI as the primary UI layer, Swift Concurrency plus Observation for state flow, SwiftData for the initial local store, UserNotifications for alerts, Apple Charts for analytics, and `MenuBarExtra` for menu bar integration.

The v1 bias should be:

1. Prefer Apple frameworks first.
2. Add AppKit only at the integration edges SwiftUI still does not cover cleanly.
3. Avoid third-party runtime dependencies unless they remove a proven limitation, not a hypothetical one.

## Recommended Stack

### Core Technologies

| Technology | Version | Purpose | Why Recommended | Confidence |
|------------|---------|---------|-----------------|------------|
| Swift | 6.x | Primary language | Native Apple development standard, strong concurrency model, long-term platform support, and best fit for SwiftUI/Observation/App Intents/SwiftData. | HIGH |
| SwiftUI | Latest stable in the chosen Xcode toolchain | App UI, navigation, forms, timer screens, settings, analytics views | Best native choice for a greenfield macOS app in 2026. Fast iteration, good sidebar/window patterns, clean integration with Charts, Settings, commands, and menu bar scenes. | HIGH |
| Observation + Swift Concurrency | Native language/framework features in Swift 6.x | App state, async work, timer orchestration, notification scheduling | Preferred modern replacement for Combine-heavy app state in new Apple apps. Simpler mental model, less boilerplate, and better alignment with current Apple APIs. | HIGH |
| SwiftData | Latest stable framework version in the chosen SDK | Local persistence for tasks, sessions, history, settings-adjacent domain data | Most native local-first persistence choice for a greenfield single-user Mac app. Good default when the product is offline-first and the schema is app-owned. | MEDIUM |
| UserNotifications | Current macOS SDK | Session completion alerts, one-minute break warning, configurable reminders | Native notifications pipeline for macOS. Handles local notifications cleanly without external services or background infrastructure. | HIGH |
| Charts | Current Apple Charts framework | Dashboard metrics, trends, productivity pattern visualizations | First-party charting with native SwiftUI integration, accessibility support, and enough capability for MVP analytics without third-party visualization debt. | HIGH |
| MenuBarExtra with selective AppKit bridging | Current macOS SDK | Menu bar entry, quick controls, timer visibility | Best native starting point for menu bar integration. If custom popover/window behavior exceeds SwiftUI scene support, bridge only that slice through `NSStatusItem` and `NSPopover`. | HIGH |
| OSLog | Current SDK | Structured logging and diagnostics | Native logging stack with zero dependency cost and strong tooling in Console/Xcode for timer, persistence, and notification debugging. | HIGH |

### Architecture Guidance

#### App structure

- Use the SwiftUI app lifecycle with dedicated scenes for the main window, settings, and menu bar entry.
- Keep a standard windowed app as the primary experience. Treat the menu bar surface as a companion control surface, not as the only UI.
- Use AppKit interop narrowly for any menu bar or window-management behavior that SwiftUI still handles awkwardly.

#### State and domain boundaries

- Keep timer orchestration separate from view state. The timer engine should be testable without SwiftUI.
- Model tasks, pomodoro sessions, cycle state, daily summaries, and settings as explicit domain types rather than pushing all logic into views or persistence models.
- Put persistence behind a small repository/store boundary even if v1 uses SwiftData directly. This is the hedge against future migration to a lower-level SQLite layer.

#### Persistence strategy

- Default to SwiftData for v1 because the product is single-user, offline-first, and greenfield.
- Store user preferences that do not need relational querying in `UserDefaults` via a thin settings wrapper.
- Keep analytics computation in dedicated services that read persisted sessions/tasks rather than denormalizing many dashboard-specific counters into the database too early.
- Plan for a migration path if reporting needs become SQL-heavy. SwiftData is the right starting bias, but not a reason to couple the whole app to framework-specific query behavior.

### Supporting Libraries

The default position is no required third-party libraries in v1.

| Library | Version | Purpose | When to Use | Confidence |
|---------|---------|---------|-------------|------------|
| No required third-party runtime dependencies | N/A | Keep the app native and low-complexity | Preferred default for v1. Use only Apple frameworks until a concrete gap appears. | HIGH |
| GRDB.swift | Latest stable major at implementation time | Direct SQLite access with stronger query control and migration ergonomics | Use only if SwiftData becomes a blocker for analytics queries, migrations, or deterministic persistence behavior. This is the best justified non-Apple fallback. | HIGH |
| KeyboardShortcuts | Latest stable major at implementation time | User-configurable keyboard shortcuts | Use only if the app needs polished shortcut recording beyond what native command menus and standard shortcuts provide. Do not add it preemptively. | MEDIUM |

### Development Tools

| Tool | Purpose | Notes |
|------|---------|-------|
| Xcode (current stable team standard) | Primary IDE, previews, Instruments, signing, packaging | Use the latest stable Xcode compatible with the chosen deployment target. Do not pin the project to a beta toolchain. |
| Swift Package Manager | Dependency management | Keep dependencies minimal and package-scoped. Prefer SPM over CocoaPods or manual vendoring. |
| XCTest + Swift Testing where appropriate | Unit, integration, and UI-adjacent logic tests | Keep timer logic, persistence adapters, and analytics reducers covered. UI snapshots are optional; deterministic domain tests are not. |
| Instruments | Performance and energy analysis | Important for timer accuracy, notification timing, menu bar behavior, and chart-heavy dashboard rendering. |
| `xcodebuild` in CI/local automation | Headless builds and tests | Standard native automation path; avoid custom wrappers unless they add clear value. |

## Prescriptive Framework Choices

### UI

- Use SwiftUI for all primary screens: dashboard, timer, tasks, statistics, history, and settings.
- Use `NavigationSplitView` or the equivalent modern sidebar navigation pattern for the main app shell.
- Use SwiftUI scene APIs for Settings and menu bar integration before introducing AppKit window controllers.

### Timer implementation

- Implement timer state as a domain service driven by monotonic time and persisted session transitions, not by trusting a view-local `Timer` alone.
- The UI can refresh on a short cadence, but elapsed session truth should come from stored start/pause/resume timestamps so the app remains correct across sleeps, focus changes, and restarts.
- Use structured tasks and an observable timer model instead of Combine publisher chains unless a concrete need appears.

### Persistence

- Use SwiftData models for tasks, sessions, task-session associations, and historical summaries if needed.
- Keep task status simple in v1: pending/completed, plus priority and timestamps.
- If one session can link to multiple tasks, persist the relationship explicitly and define time-allocation rules in the domain layer rather than embedding ambiguous assumptions in the schema.

### Notifications and sounds

- Use `UNUserNotificationCenter` for local notifications.
- Use native audio APIs only for the end-of-cycle sound. Keep sounds configurable but simple.
- Do not build custom background daemons or helper processes for v1 unless a concrete macOS delivery constraint forces it.

### Analytics and charts

- Use Apple Charts for trend lines, daily totals, session distribution, and task productivity comparisons.
- Keep chart requirements within first-party capabilities. The product does not need a BI stack.
- Precompute lightweight derived summaries only when profiling shows repeated aggregation is actually expensive.

### Menu bar integration

- Start with `MenuBarExtra` for a native menu bar timer/control surface.
- If the product needs a highly custom floating popover, detached panel, or advanced status-item behavior, bridge that feature with AppKit instead of abandoning SwiftUI for the entire app.
- Keep menu bar controls focused: current state, remaining time, quick start/pause/reset, and open-main-window action.

## Installation / Dependency Policy

There is no required package install for the recommended v1 runtime stack beyond the Xcode toolchain.

If an optional dependency becomes justified later:

```bash
# Add only if SwiftData proves limiting
swift package add https://github.com/groue/GRDB.swift

# Add only if native shortcut recording is insufficient
swift package add https://github.com/sindresorhus/KeyboardShortcuts
```

If the project is initialized as an Xcode app target instead of a standalone package, add optional dependencies through Swift Package Manager in Xcode rather than vendoring code manually.

## Alternatives Considered

| Recommended | Alternative | When to Use Alternative |
|-------------|-------------|-------------------------|
| SwiftUI-first app | AppKit-first app | Choose AppKit-first only if the product becomes heavily window-manager-like, requires deep custom control chrome everywhere, or SwiftUI proves materially limiting after prototyping. That is not the expected case here. |
| SwiftData | GRDB.swift / raw SQLite | Choose this when analytics, migrations, query predictability, or data inspection become more important than staying on the highest-level Apple persistence framework. |
| Apple Charts | Third-party charting library | Use a third-party charting library only if Apple Charts cannot express a specifically required visualization. For v1, that threshold should not be met. |
| Observation + Swift Concurrency | Combine-centric MVVM | Use Combine only when integrating with legacy reactive code or a specific API surface that truly benefits from it. It should not be the default state architecture for a new 2026 macOS app. |
| `MenuBarExtra` with AppKit edge bridging | Fully custom status bar infrastructure from day one | Use custom status bar plumbing only after confirming SwiftUI scene APIs cannot provide the required UX. |

## What NOT to Use

| Avoid | Why | Use Instead |
|-------|-----|-------------|
| Electron, Tauri, or any packaged web stack for v1 | Violates the product goal of feeling like a real native Mac app, adds unnecessary runtime and packaging complexity, and weakens integration with menu bar, notifications, and native settings. | Swift + SwiftUI |
| Flutter or React Native Desktop | Cross-platform abstraction adds little value for a macOS-only product and usually produces weaker platform fit than native APIs. | SwiftUI with selective AppKit bridging |
| CocoaPods or manual framework vendoring | Unnecessary dependency management overhead for a modern Apple app and a poor fit for a minimal-dependency strategy. | Swift Package Manager |
| Combine-heavy architecture as the default | Adds ceremony and indirection where Observation plus structured concurrency is simpler and more maintainable for new code. | Observation + async/await |
| Realm or Firebase-backed local-first design for v1 | Introduces non-native persistence tradeoffs and future product assumptions the brief explicitly does not need, especially since there is no account or sync requirement. | SwiftData first, GRDB if needed |
| Third-party charting libraries by default | Extra dependency surface for a problem first-party Charts already covers well enough at MVP scope. | Apple Charts |
| CloudKit sync in the first milestone | The brief is personal, offline-first, and no-login. Sync is deferred product work, not foundational scope. | Local-only persistence |
| Persisting all settings in the main database | Over-models simple preferences and creates friction for basic configuration reads/writes. | `UserDefaults` through a typed settings layer |

## Stack Patterns by Variant

**If v1 remains strictly local and single-user:**
- Use SwiftData + `UserDefaults`.
- Keep all runtime dependencies first-party.
- This is the default and recommended path.

**If analytics become query-heavy during implementation:**
- Keep the SwiftUI UI stack, but replace or isolate persistence reads behind GRDB.
- Do not rewrite the app architecture; swap the store implementation behind repository boundaries.
- Confidence: HIGH.

**If menu bar UX needs a detached floating panel or advanced status-item behavior:**
- Keep the app SwiftUI-first.
- Introduce AppKit only for status item and window/panel control.
- Do not convert the rest of the UI to AppKit.
- Confidence: HIGH.

**If the app later adds sync or multi-device usage:**
- Preserve the local domain model and repository boundary.
- Reevaluate persistence and conflict handling then; do not design the v1 stack around speculative sync.
- Confidence: HIGH.

## Version Compatibility

| Component | Compatible With | Notes |
|-----------|-----------------|-------|
| Swift 6.x | Current stable Xcode team standard | Use the latest stable toolchain, not beta-only language features. |
| SwiftUI + Charts + MenuBarExtra | Modern macOS deployment target chosen for the app | Set the minimum macOS target high enough to avoid fighting backward-compatibility shims for first-party UI APIs. |
| SwiftData | Modern macOS deployment target chosen for the app | Highest risk area in the stack. Keep persistence behind boundaries so the app can move to GRDB if needed. |
| UserNotifications + OSLog | Modern macOS deployment target chosen for the app | Safe native defaults with broad support across recent macOS releases. |

## Final Recommendation

For this project, the right 2026-native stack is:

- Swift 6.x
- SwiftUI for the full primary UI
- Observation + Swift Concurrency for state and async behavior
- SwiftData for initial local persistence
- `UserDefaults` for lightweight preferences
- UserNotifications for alerts
- Apple Charts for analytics
- `MenuBarExtra`, with AppKit used only when SwiftUI menu bar APIs are insufficient
- OSLog, XCTest, Swift Package Manager, Instruments, and `xcodebuild` as the core tooling set

Do not start with cross-platform UI, custom persistence infrastructure, or third-party visualization packages. The correct bias is native-first, minimal-dependency, and easy to evolve if one specific framework becomes the bottleneck.

## Sources

- [.planning/PROJECT.md](/Users/nicolasguerrero/Projects/personal/pomodoro/.planning/PROJECT.md) - Product scope, constraints, and explicit platform decisions
- [STACK template](/Users/nicolasguerrero/Projects/personal/pomodoro/.codex/get-shit-done/templates/research-project/STACK.md) - Required research document structure
- Apple platform conventions and current native macOS application architecture practice - Used for stack recommendations and confidence assessments

---
*Stack research for: native macOS Pomodoro/productivity app*
*Researched: 2026-03-06*
