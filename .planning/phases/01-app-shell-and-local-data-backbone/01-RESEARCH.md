# Phase 1: App Shell and Local Data Backbone - Research

**Researched:** 2026-03-06
**Domain:** Native macOS SwiftUI app shell, local-first persistence, and offline bootstrap
**Confidence:** HIGH

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions
- The landing Dashboard should feel timer-first rather than analytics-first.
- The Dashboard should use a balanced layout: clear primary focus area plus a few supporting cards, without feeling sparse or crowded.
- When there is no user data yet, show honest empty cards rather than fake preview metrics.
- The main Dashboard action should guide the user to create the first task before deeper usage.
- First-run copy should be calm and direct, not hype-driven or overly chatty.
- The empty Dashboard should include a short checklist that helps the user get started.
- The app should start with no sample data; all content should reflect the user’s real activity.
- Sidebar sections should still open as real pages with concise explanations of what will appear there over time.
- The shell should feel Mac-native, using a standard desktop sidebar with icons and labels.
- Sidebar sizing should follow the normal macOS collapse/show behavior rather than inventing a custom navigation pattern.
- Settings should live as a regular sidebar section inside the shell, not as a separate settings window in Phase 1.
- Unpopulated sections should use quiet explanatory copy rather than teaser states or silence.

### Claude's Discretion
- Exact Dashboard card composition and spacing, as long as it stays timer-first and balanced.
- Exact wording of the checklist and empty-state helper copy, as long as it stays calm and direct.
- Exact icon choices and visual styling details within a restrained native macOS feel.
- Main-window behavior details not explicitly discussed, using sensible native defaults unless later planning finds a reason to surface a choice.

### Deferred Ideas (OUT OF SCOPE)
- None.
</user_constraints>

<research_summary>
## Summary

Phase 1 should establish a conventional macOS SwiftUI shell, not invent a custom desktop framework. The standard approach is a `SwiftUI App` entry point, one shared `ModelContainer`, a `NavigationSplitView`-based sidebar shell, and a small app environment that injects repositories and settings services into feature views. This matches the project’s local-first and offline-only constraints while keeping later phases free to add the timer engine, analytics, and menu bar behaviors on stable seams rather than retrofitting them into view code.

The Dashboard should launch as the selected detail destination on every cold start and remain honest on day one: a timer-oriented primary card, calm helper copy, a short checklist, and secondary cards that clearly say there is no focus history yet. The phase should not fake metrics, restore the last visited route, or block launch on permissions. Bootstrapping should register default settings, open the local store, wire dependencies, and present the shell even if the data set is empty.

The highest planning risk is persistence shape, not layout. SwiftData is the correct Phase 1 default, but only behind repository protocols so later phases can swap to GRDB or direct SQLite if analytics queries become more demanding. Phase 1 should also reserve a durable place for future active-session recovery, because relaunch-safe timer work in Phase 3 becomes harder if the store only models finished history.

**Primary recommendation:** Build Phase 1 around `NavigationSplitView` + `SwiftData` + a thin repository/settings boundary, and treat first-launch empty states and relaunch-safe storage seams as the real deliverable.
</research_summary>

<standard_stack>
## Standard Stack

The established libraries/tools for this phase:

### Core
| Library / Framework | Version | Purpose | Why Standard |
|---------------------|---------|---------|--------------|
| Swift | 6.x | Primary language | Current native Apple baseline with modern concurrency and observation support. |
| SwiftUI | Current stable Xcode SDK | App entry, shell, sidebar, dashboard, section placeholders | Native-first macOS UI framework with standard scene and split-view APIs. |
| SwiftData | Current stable Xcode SDK | Local-first persistence for tasks, sessions, links, and future active-session snapshots | Best greenfield Apple-first default for a single-user offline macOS app. |
| Observation | Current stable Xcode SDK | Shared app state and service-backed UI observation | Current Apple guidance for new code instead of `ObservableObject`-heavy patterns. |
| Foundation `UserDefaults` | Current stable Xcode SDK | Lightweight settings and first-launch defaults | Correct place for preferences that do not need relational queries. |

### Supporting
| Library / Framework | Version | Purpose | When to Use |
|---------------------|---------|---------|-------------|
| `NavigationSplitView` | Current stable Xcode SDK | Sidebar + detail shell | Use as the default app shell for macOS sidebar navigation. |
| `MenuBarExtra` | Current stable Xcode SDK | Future menu bar projection | Do not fully implement in Phase 1, but keep the app environment ready for a shared timer state later. |
| `UserNotifications` | Current stable Xcode SDK | Future local alerts | No full notification flow yet, but Phase 1 should avoid any bootstrap design that would block adding local notifications later. |
| `OSLog` | Current stable Xcode SDK | Startup, persistence, and recovery diagnostics | Use from the start so store/bootstrap failures are inspectable. |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| SwiftData repository-backed store | GRDB / direct SQLite | Stronger query and migration control, but unnecessary complexity before real analytics pressure appears. |
| `NavigationSplitView` shell | Custom AppKit sidebar chrome | More control, but slower and riskier for a phase whose value is native structure rather than custom navigation. |
| Observation-backed app environment | `ObservableObject` + `@Published` everywhere | Works, but more boilerplate and not the current Apple-first bias for greenfield code. |

**Installation / project setup:**
```text
Create a native macOS SwiftUI app target with tests enabled.
Set the deployment target to macOS 14+ so SwiftData and modern observation APIs are first-class.
Keep third-party runtime dependencies at zero for this phase.
```
</standard_stack>

<architecture_patterns>
## Architecture Patterns

### Recommended Project Structure
```text
PomodoroMac/
├── App/
│   ├── PomodoroMacApp.swift
│   ├── AppEnvironment.swift
│   └── Navigation/
│       ├── AppSection.swift
│       └── AppRouter.swift
├── Features/
│   ├── Dashboard/
│   ├── Timer/
│   ├── Tasks/
│   ├── Statistics/
│   ├── History/
│   └── Settings/
├── Domain/
│   ├── Models/
│   └── Policies/
├── Infrastructure/
│   ├── Persistence/
│   │   ├── Models/
│   │   ├── Repositories/
│   │   └── ModelContainerFactory.swift
│   └── Settings/
└── Tests/
    ├── Unit/
    └── Integration/
```

### Pattern 1: SwiftUI Scene Shell With Explicit Sidebar Routing
**What:** Use a `WindowGroup` root view with `NavigationSplitView`, an enum-backed sidebar selection, and Dashboard selected by default.
**When to use:** Immediately in Plan `01-01`.
**Why:** This gives the user the full v1 section map on day one while keeping each destination a real page, even if some sections only show explanatory empty content in Phase 1.

Recommended planner guidance:
- Model `AppSection` as a stable enum with six cases: `dashboard`, `timer`, `tasks`, `statistics`, `history`, `settings`.
- Default cold-launch selection to `.dashboard`.
- Do not restore last-selected sidebar section yet, because the roadmap success criterion explicitly says the user lands on Dashboard.
- Keep section content views separate from the shell so later phases can replace placeholder copy without rewriting navigation.

### Pattern 2: Thin App Environment, Not Global Singletons
**What:** Build one top-level environment object/struct that owns repositories, settings access, and future timer/session services.
**When to use:** In Plans `01-01` and `01-02`.
**Why:** The project is greenfield and local-only; a small dependency container is enough. It should wire the shell cleanly without turning SwiftUI views into service locators or scattering `ModelContext` usage through feature code.

Recommended planner guidance:
- `PomodoroMacApp` owns container creation.
- `AppEnvironment` injects repository protocols and a typed settings service.
- Views can observe high-level feature models, but persistence APIs should stay behind repositories.
- Reserve a place in the environment for a future `TimerCoordinator`, even if Phase 1 only uses a stub.

### Pattern 3: Local Store Boundary Split by Data Type
**What:** Use SwiftData for queryable domain records and `UserDefaults` for lightweight configuration.
**When to use:** In Plan `01-02`.
**Why:** This keeps the local-first promise without over-modeling simple preferences in the database or under-modeling historical data in key-value storage.

Recommended persistent split:
- `SwiftData`: tasks, completed tasks, session history, task-session links, and a future `ActiveSessionSnapshot`.
- `UserDefaults`: app defaults such as selected durations, auto-start preferences, first-launch checklist dismissal state, and other lightweight toggles.
- Repositories convert between persistence models and domain-facing value types so the app is not forced into SwiftData-specific APIs later.

### Pattern 4: Offline-Safe Bootstrap Pipeline
**What:** Treat launch as a local dependency bootstrap, not as an onboarding wizard or remote handshake.
**When to use:** In Plan `01-03`.
**Why:** Requirement `CONF-04` means the full v1 app must be usable without internet. Phase 1 should prove that the shell can always open from disk state alone.

Recommended launch sequence:
1. Register default settings in `UserDefaults`.
2. Build the `ModelContainer` using a stable Application Support store location.
3. Construct repositories and app environment.
4. Read any future active-session snapshot and expose recovery state, but do not require timer UI logic yet.
5. Present Dashboard immediately, even with zero data.
6. Log container/bootstrap failures with `OSLog` and show a recoverable fallback view if store creation fails.

### Anti-Patterns to Avoid
- **Custom shell chrome:** Do not invent a custom split view, resizer, or faux sidebar when `NavigationSplitView` already matches the product brief.
- **Views owning persistence logic:** Do not inject raw `ModelContext` into every page and let feature views save directly to storage.
- **Database for simple preferences:** Do not store every checkbox and duration preset in SwiftData.
- **Fake onboarding data:** Do not pre-seed tasks, sessions, or dashboard metrics just to make the first launch look busy.
- **Last-route restoration in Phase 1:** It conflicts with the success criterion that app launch lands on Dashboard.
</architecture_patterns>

<dont_hand_roll>
## Don't Hand-Roll

Problems that look simple but have existing solutions:

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Native sidebar shell | Custom AppKit split-view container and manual resize behavior | `NavigationSplitView` | macOS already provides the exact interaction model the phase requires. |
| Local preferences registry | JSON/plist files with ad hoc read/write wrappers | `UserDefaults` behind a typed settings service | Lower failure surface and easier defaults registration for offline launch. |
| Local-first data store | Hand-rolled JSON database or direct file blobs for tasks/history | SwiftData `ModelContainer` behind repositories | Querying, relationships, and later analytics become much easier. |
| Shared app state | Global mutable singletons | One explicit app environment injected from the `App` entry point | Easier testing, clearer lifecycle, fewer hidden dependencies. |
| First-launch visual activity | Seeded fake metrics or sample task history | Honest empty cards and explanatory copy | Product intent explicitly rejects fake data. |

**Key insight:** Phase 1 should not spend time replacing mature Apple primitives with custom infrastructure. The durable value is in the boundaries between shell, storage, settings, and future timer recovery.
</dont_hand_roll>

<common_pitfalls>
## Common Pitfalls

### Pitfall 1: Coupling Sidebar Navigation to Placeholder Content
**What goes wrong:** The team delays adding real destinations because only Dashboard is populated, then later phases have to restructure navigation and route types.
**Why it happens:** It is tempting to build a single-window dashboard view first and “add the rest later.”
**How to avoid:** Ship all six sidebar destinations in Phase 1 as real pages with stable route cases and concise explanatory copy.
**Warning signs:** The shell uses hard-coded strings instead of an app section enum, or unimplemented sections are missing entirely from the sidebar.

### Pitfall 2: No Persistence Boundary Around SwiftData
**What goes wrong:** Future analytics and history features become tied to view-specific `@Query` usage and ad hoc `ModelContext` mutations.
**Why it happens:** SwiftData feels ergonomic enough that teams skip repository seams in the first milestone.
**How to avoid:** Keep write operations in repositories/services now and allow feature views to depend on feature-facing models rather than raw persistence APIs.
**Warning signs:** Views create, mutate, and save models directly across multiple screens, or there is no obvious place to change persistence technology later.

### Pitfall 3: Bootstrap Fails Hard on Store Initialization
**What goes wrong:** The app uses `try!` or `fatalError` for store creation and becomes non-launchable if the local store is unavailable or corrupted.
**Why it happens:** Early prototypes often assume the local store always opens successfully.
**How to avoid:** Encapsulate container creation in a factory that logs failures, surfaces a recoverable error state, and keeps bootstrap logic testable.
**Warning signs:** `ModelContainer` creation lives inline in the `App` body with no error handling or diagnostics.

### Pitfall 4: Preferences and History Share the Same Persistence Strategy
**What goes wrong:** Either settings become awkward database rows, or history ends up in key-value storage that cannot support filtering and analytics.
**Why it happens:** Teams optimize for whichever storage method they wire up first.
**How to avoid:** Make the split explicit in the phase plan: `UserDefaults` for preferences, SwiftData for queryable records.
**Warning signs:** The schema contains rows for simple booleans like “auto start breaks,” or `UserDefaults` keys start accumulating session totals.

### Pitfall 5: First Launch Looks Busy but Is Dishonest
**What goes wrong:** The dashboard ships with preview numbers or seed sessions that users mistake for real data.
**Why it happens:** Blank states can feel visually risky, especially before tasks and timer features exist.
**How to avoid:** Design a balanced empty dashboard with one primary “ready to focus” card, checklist guidance, and empty secondary cards that state there is no real data yet.
**Warning signs:** Metric cards show non-zero values on a clean install, or the dashboard copy implies activity the user has not done.
</common_pitfalls>

<code_examples>
## Code Examples

Verified patterns from official sources and the project’s Apple-first stack direction:

### App Shell With Shared Model Container
```swift
// Source pattern: Apple SwiftData ModelContainer + SwiftUI App scene composition
// https://developer.apple.com/documentation/swiftdata/modelcontainer

@main
struct PomodoroMacApp: App {
    @State private var environment = AppEnvironment.bootstrap()

    var body: some Scene {
        WindowGroup {
            AppShellView()
                .environment(environment)
        }
        .modelContainer(environment.sharedModelContainer)
    }
}
```

### Sidebar Shell With Dashboard as Default Selection
```swift
// Source pattern: Apple NavigationSplitView
// https://developer.apple.com/documentation/swiftui/navigationsplitview

enum AppSection: String, CaseIterable, Identifiable {
    case dashboard, timer, tasks, statistics, history, settings

    var id: String { rawValue }
}

struct AppShellView: View {
    @State private var selection: AppSection? = .dashboard

    var body: some View {
        NavigationSplitView {
            List(AppSection.allCases, selection: $selection) { section in
                Label(section.rawValue.capitalized, systemImage: symbol(for: section))
                    .tag(section)
            }
            .navigationTitle("Pomodoro")
        } detail: {
            AppSectionView(section: selection ?? .dashboard)
        }
    }
}
```

### Local Notification Permission Boundary
```swift
// Source pattern: Apple UserNotifications authorization and local scheduling
// https://developer.apple.com/documentation/usernotifications/asking-permission-to-use-notifications
// https://developer.apple.com/documentation/usernotifications/scheduling-a-notification-locally-from-your-app

import UserNotifications

struct NotificationPermissionService {
    func requestIfNeeded() async throws -> Bool {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()

        if settings.authorizationStatus == .notDetermined {
            return try await center.requestAuthorization(options: [.alert, .sound])
        }

        return settings.authorizationStatus == .authorized
    }
}
```
</code_examples>

<sota_updates>
## State of the Art (2024-2025)

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| `NavigationView` for sidebar apps | `NavigationSplitView` for macOS shells | SwiftUI’s newer navigation APIs | Better fit for standard desktop sidebar structure and less custom navigation plumbing. |
| `ObservableObject` + `@Published` everywhere | Observation-first state for greenfield Apple apps | Post-Observation adoption cycle | Less boilerplate and a cleaner app environment for injected services. |
| Core Data template as the default Apple local store choice | SwiftData for greenfield native apps, with an escape hatch for heavier query needs | SwiftData era | Faster setup for local-first apps, but only safe if repository seams remain intact. |
| Separate settings window by default | Settings may live in-app when product navigation requires it | Modern app-shell patterns | Matches this phase’s requirement that Settings be a regular sidebar destination. |

**New tools/patterns to consider:**
- Observation-backed service ownership from the `App` entry point instead of wide Combine-driven view models.
- Container factories for SwiftData store creation so bootstrap failures are diagnosable and recoverable.

**Deprecated/outdated for this project:**
- Custom desktop chrome for basic sidebar navigation.
- Fake seed analytics to make a greenfield dashboard appear populated.
</sota_updates>

<open_questions>
## Open Questions

1. **How much active-session recovery structure should Phase 1 model before the timer exists?**
   - What we know: Relaunch safety is a roadmap concern and the project state already calls out recovery foundations as part of Plan `01-03`.
   - What's unclear: Whether the phase should persist only a placeholder snapshot type or a fuller session-recovery schema now.
   - Recommendation: Add a narrow `ActiveSessionSnapshot` persistence model and repository seam in Phase 1, but keep timer transition logic deferred to Phase 3.

2. **Should the app commit to SwiftData long-term or only for initial scaffolding?**
   - What we know: SwiftData is the recommended Apple-first default and sufficient for Phase 1 requirements.
   - What's unclear: Whether future statistics/history queries will outgrow SwiftData ergonomics.
   - Recommendation: Plan Phase 1 around SwiftData, but make repository protocols mandatory so later phases can migrate the store without a UI rewrite.

3. **Should the dashboard checklist state persist?**
   - What we know: The first-launch Dashboard should contain a short checklist and honest empty cards.
   - What's unclear: Whether checklist items are purely derived from existing data or partially user-dismissable.
   - Recommendation: Prefer derived checklist completion from real app state first. Only persist dismissals in `UserDefaults` if the planner decides there is real UX value.
</open_questions>

## Planning Implications

### Recommended Sequencing Across the Three Phase 1 Plans

**Plan 01-01: Scene structure and shell**
- Create the macOS SwiftUI app target and test target.
- Establish `PomodoroMacApp`, `AppEnvironment`, `AppSection`, and `NavigationSplitView`.
- Implement all sidebar destinations as real views, with Dashboard as the default selection.
- Build the no-data Dashboard shape with calm copy, checklist guidance, and honest empty cards.

**Plan 01-02: Persistence boundary**
- Define SwiftData models for tasks, session history, task-session links, and a narrow future active-session snapshot.
- Build repository protocols plus SwiftData-backed implementations.
- Add typed settings access over `UserDefaults`.
- Keep feature views from depending directly on raw `ModelContext` mutations.

**Plan 01-03: Offline-safe bootstrap and relaunch foundations**
- Centralize bootstrap in a factory that registers defaults, opens the store, wires services, and logs failures.
- Decide fallback behavior when store creation fails.
- Add initial recovery plumbing that can detect a persisted future active-session snapshot without implementing the timer yet.
- Verify that a clean install, restart, and no-network environment all land on Dashboard successfully.

### Planner-Facing Risks

| Risk | Why It Matters | Planning Response |
|------|----------------|------------------|
| SwiftData lock-in | Statistics and history phases may need different query ergonomics later | Require repository seams in this phase. |
| Overbuilding the dashboard | Fake or speculative metrics will become design debt immediately | Keep the dashboard timer-first and empty-state honest. |
| Route restoration conflict | Restoring last route can violate the requirement to land on Dashboard | Make Dashboard the cold-start default and revisit restoration later if needed. |
| Bootstrap brittleness | A local-only app that fails to launch because the store fails breaks the core promise | Design a recoverable bootstrap path and log startup failures. |
| Timer recovery arriving too late | Phase 3 relaunch safety is harder if Phase 1 ignores in-progress session storage completely | Reserve the storage seam now without implementing timer behavior early. |

## Validation Architecture

Phase 1 is a good candidate for an initial validation file once the app target and test target exist, but the planner should assume Wave 0 test setup is part of `01-01` because the repository currently has no app code or Xcode test infrastructure.

### Recommended Test Infrastructure

| Property | Recommendation |
|----------|----------------|
| Framework | `XCTest` for unit and integration-level app tests |
| Quick run command | `xcodebuild test -scheme PomodoroMac -destination 'platform=macOS'` |
| Full suite command | Same in Phase 1, because the suite should stay small initially |
| Estimated runtime target | Under 60 seconds for Phase 1 |

### What to Validate in Phase 1

| Area | Verification Type | Notes |
|------|-------------------|-------|
| Default sidebar route is Dashboard | Automated unit/UI-shell test | Protects `DASH-01` and avoids accidental route restoration. |
| All six sidebar sections exist | Automated test | Confirms `CONF-05` shell completeness. |
| Store-backed data survives relaunch | Automated integration test | Seed a task/session record, recreate environment, confirm it reloads. |
| App boot does not require network | Manual plus design-level contract | There should be no network client in bootstrap at all. |
| Empty dashboard remains honest | Manual snapshot/review or UI test | Check that cards show empty-state copy, not fake metrics. |
| Bootstrap error path is recoverable | Automated unit test around container factory if feasible | Avoid `fatalError` launch behavior. |

### Suggested Wave 0 Validation Tasks

- Create an `XCTest` target during app project setup.
- Add shell navigation tests for default selection and section enumeration.
- Add persistence smoke tests that create and reopen the shared model container.
- Add bootstrap tests around default settings registration and failure handling where practical.

### Manual-Only Behaviors

| Behavior | Requirement / Goal | Why Manual |
|----------|--------------------|------------|
| Dashboard visual balance on a clean install | Phase goal and context constraints | Layout quality and copy tone are subjective. |
| Sidebar native feel and collapse behavior | `CONF-05` and shell quality | Native desktop feel is easier to judge interactively than in unit tests. |
| Clean relaunch with no connectivity | `CONF-04` | Best verified by running the app offline and relaunching from a cold state. |

<sources>
## Sources

### Primary (HIGH confidence)
- https://developer.apple.com/documentation/swiftui/navigationsplitview - Standard macOS sidebar shell pattern.
- https://developer.apple.com/documentation/swiftdata/modelcontainer - Shared local persistence container shape and app wiring.
- https://developer.apple.com/documentation/swiftui/menubarextra - Future menu bar scene pattern that Phase 1 should not block.
- https://developer.apple.com/documentation/usernotifications/asking-permission-to-use-notifications - Notification authorization boundary for future phases.
- https://developer.apple.com/documentation/usernotifications/scheduling-a-notification-locally-from-your-app - Local notification scheduling model for future timer flows.
- https://developer.apple.com/documentation/swiftui/migrating-from-the-observable-object-protocol-to-the-observable-macro - Current Apple guidance on observation for new code.

### Secondary (HIGH confidence within this repo)
- `.planning/REQUIREMENTS.md` - Phase 1 requirement mapping and success criteria.
- `.planning/ROADMAP.md` - Three-plan breakdown for Phase 1.
- `.planning/STATE.md` - Current concern about SwiftData persistence boundary and relaunch foundations.
- `.planning/phases/01-app-shell-and-local-data-backbone/01-CONTEXT.md` - Locked UX and shell decisions for this phase.
- `.planning/research/SUMMARY.md` - Project-level Apple-first stack and architecture direction.
- `.planning/research/STACK.md` - Stack recommendation and persistence tradeoff summary.
- `.planning/research/ARCHITECTURE.md` - Service and repository layering guidance.
- `.planning/research/PITFALLS.md` - Recovery, persistence, and analytics risk framing.
</sources>

<metadata>
## Metadata

**Research scope:**
- Core technology: SwiftUI macOS shell, SwiftData local persistence, settings storage, launch bootstrap
- Ecosystem: Apple-first native frameworks only
- Patterns: sidebar shell, repository boundary, typed settings service, recoverable bootstrap
- Pitfalls: dishonest empty states, brittle container startup, missing storage seams, shell/persistence coupling

**Confidence breakdown:**
- Standard stack: HIGH - The project constraints align strongly with Apple’s standard native stack.
- Architecture: HIGH - The shell/repository/bootstrap boundaries are stable and well supported by the roadmap.
- Pitfalls: HIGH - Risks map directly to this phase’s success criteria and the project-level pitfalls research.
- Code examples: MEDIUM - They are intentionally skeletal and meant to anchor planning, not compile unchanged.

**Research date:** 2026-03-06
**Valid until:** 2026-04-05
</metadata>

---
*Phase: 01-app-shell-and-local-data-backbone*
*Research completed: 2026-03-06*
*Ready for planning: yes*
