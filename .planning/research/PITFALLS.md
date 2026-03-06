# Pitfalls Research

**Domain:** Native macOS Pomodoro and personal productivity app
**Researched:** 2026-03-06
**Confidence:** HIGH

This project is greenfield, local-first, macOS-only, and explicitly broader than a simple timer. The main risk is not building the countdown UI. The main risk is shipping a system that appears to work while producing incorrect sessions, misleading analytics, or inconsistent menu bar behavior under normal desktop conditions.

## Suggested Prevention Phases

These are suggested planning buckets so the pitfalls map cleanly into future roadmap phases.

- **Phase A: Timer Engine and Session State Model**  
Define the single source of truth for timer state, cycle progression, pause/resume semantics, sleep/wake handling, and reset behavior.
- **Phase B: Persistence and Crash Recovery**  
Design local storage, write boundaries, durable session records, recovery on relaunch, and migration safety.
- **Phase C: Notifications and Menu Bar Integration**  
Integrate notification permissions, scheduling strategy, menu bar state, and app lifecycle behavior.
- **Phase D: Task Attribution and Analytics Semantics**  
Lock rules for task assignment, multi-task attribution, history events, and derived metrics.
- **Phase E: Verification, Instrumentation, and Edge-Case QA**  
Exercise sleep/wake, app termination, relaunch, denied notifications, and analytics reconciliation.

## Critical Pitfalls

### Pitfall 1: Timer Drift From Wall-Clock Assumptions

**What goes wrong:**  
The countdown appears correct while the app is foregrounded, but sessions become wrong after sleep, wake, clock changes, app suspension, or heavy main-thread load. Work sessions may finish early, late, or twice.

**Why it happens:**  
Developers often drive the timer from repeating UI ticks or `Timer` callbacks and treat each tick as elapsed time. On macOS, sleep/wake and scheduling delays break that assumption.

**How to avoid:**  
Model sessions from persisted timestamps and explicit session state, not from tick counts. Use a monotonic elapsed-time strategy for active timing, recompute remaining time from authoritative start/pause/resume markers, and treat the UI ticker as a rendering detail only. Add explicit sleep/wake reconciliation logic.

**Warning signs:**  
- Remaining time changes by more than one second after wake.
- Completed-session counts differ depending on whether the app stayed open.
- Tests only cover a foreground happy path and not sleep/wake or clock changes.

**Phase to address:**  
Phase A, verified again in Phase E.

---

### Pitfall 2: Multiple Timer Authorities Create State Divergence

**What goes wrong:**  
The main window, menu bar, notifications, and persisted history disagree about whether a timer is running, paused, or completed. Users see one state in the menu bar and another in the main timer screen.

**Why it happens:**  
Greenfield desktop apps often let each surface manage its own timer state for convenience. That works in demos and fails once multiple windows, background behavior, and relaunch enter the picture.

**How to avoid:**  
Create one authoritative timer/session store and make every surface subscribe to it. All commands such as start, pause, reset, skip break, or assign task should go through the same reducer or state transition layer. Disallow ad hoc state mutation from UI views.

**Warning signs:**  
- The menu bar can pause or resume the timer without the main view updating immediately.
- Resetting from one surface leaves stale notifications or stale history rows.
- View models duplicate timer state fields instead of reading a shared source.

**Phase to address:**  
Phase A and Phase C.

---

### Pitfall 3: Notification Logic Assumes Delivery Instead of Verifying It

**What goes wrong:**  
Break warnings, cycle-end alerts, or sounds silently fail because notification permission was denied, alerts were suppressed, or scheduled notifications no longer match the current timer state.

**Why it happens:**  
Developers treat local notifications as fire-and-forget. On macOS, permission status, user settings, focus modes, and stale scheduled notifications matter.

**How to avoid:**  
Handle notification authorization as product state, not a one-time setup detail. Build notification scheduling around session identifiers so pending alerts can be replaced or canceled when the timer changes. Expose a graceful fallback when notifications are unavailable, and test denied-permission flows early.

**Warning signs:**  
- No visible in-app indication that notifications are disabled.
- Resetting or changing durations leaves old pending notifications.
- The one-minute break warning fires for a break that was skipped.

**Phase to address:**  
Phase C, verified in Phase E.

---

### Pitfall 4: Menu Bar Integration Becomes a Separate App Instead of a Surface

**What goes wrong:**  
The menu bar item gets out of sync, disappears after relaunch, opens the wrong window, or handles user actions differently from the main app. Users stop trusting it and treat the app as unreliable.

**Why it happens:**  
Menu bar integrations are easy to prototype but easy to over-specialize. Teams often bolt on a second interaction model without defining lifecycle ownership, startup behavior, or conflict resolution with the main app scene.

**How to avoid:**  
Treat the menu bar as a thin projection of shared application state. Define launch behavior, reopen behavior, and foreground/background expectations explicitly. Keep menu bar commands limited to operations already supported by the core state layer, and cover edge cases like app relaunch with an active session.

**Warning signs:**  
- The menu bar label updates on a different cadence than the timer screen.
- Relaunch behavior is undefined when a session was mid-flight.
- Menu actions trigger separate code paths from the main app.

**Phase to address:**  
Phase C, with timer-state prerequisites from Phase A.

---

### Pitfall 5: Session Persistence Records Outcomes Too Late

**What goes wrong:**  
If the app crashes, is force-quit, or restarts during a session, the timer either disappears entirely or comes back in an incorrect state. History becomes impossible to reconcile because only completed sessions were stored.

**Why it happens:**  
A common shortcut is to persist only the final result of a completed Pomodoro. That loses the facts needed to recover an in-progress or partially completed session.

**How to avoid:**  
Persist session intent and state transitions durably enough to recover. Store session identity, start time, paused intervals, current phase, linked task IDs, and terminal outcome. Design explicit rules for what counts as completed, canceled, interrupted, or abandoned after relaunch.

**Warning signs:**  
- In-progress sessions exist only in memory.
- Crash recovery behavior is described as "we'll just reset it."
- History rows do not distinguish completed vs. canceled vs. interrupted sessions.

**Phase to address:**  
Phase B, verified in Phase E.

---

### Pitfall 6: Analytics Are Computed From Mutable UI State Instead of Stable Events

**What goes wrong:**  
Dashboard totals, streaks, per-task time, and historical charts drift over time or change after task edits. Users lose trust when yesterday's numbers change after they rename or complete a task today.

**Why it happens:**  
Developers often derive analytics directly from current task fields or from incomplete session tables. That works until tasks can be reassigned, renamed, or completed after the session happened.

**How to avoid:**  
Base analytics on immutable session/history events and explicit attribution snapshots. Define which data is historical fact and which data is current task metadata. Recompute dashboards from stable records, and keep derived aggregates reproducible from source events.

**Warning signs:**  
- Editing a task title or priority changes historical totals unexpectedly.
- Different screens compute the same metric with different queries.
- There is no written metric definition for "time spent," "completed Pomodoros," or "completed tasks."

**Phase to address:**  
Phase D, with storage support from Phase B.

---

### Pitfall 7: Multi-Task Attribution Rules Stay Ambiguous Too Long

**What goes wrong:**  
The app allows linking multiple tasks to a session, but no one can explain how time, Pomodoro count, or completion credit should be split. Statistics become arbitrary and users cannot interpret them.

**Why it happens:**  
This is a product semantics problem disguised as a data problem. Teams defer the decision because supporting multiple selected tasks looks harmless in the UI.

**How to avoid:**  
Choose attribution rules before building analytics. Options include one primary task per session, equal split across selected tasks, manual percentages, or "session linked to many tasks but credited to one canonical task." Record the chosen attribution snapshot on the session itself so later rule changes do not rewrite history.

**Warning signs:**  
- The UI allows multiple selected tasks but the data model has only one task foreign key.
- Team discussions use vague phrases like "we can figure out reporting later."
- Mockups show per-task metrics without a formal allocation rule.

**Phase to address:**  
Phase D.

---

### Pitfall 8: Reset, Skip, and Auto-Start Semantics Are Not Treated as First-Class State Transitions

**What goes wrong:**  
Users hit reset, skip a break, or enable auto-start and end up with duplicate sessions, orphaned notifications, or phantom break records. Fixed four-cycle behavior becomes inconsistent across edge cases.

**Why it happens:**  
These actions are often implemented as convenience buttons after the main timer works. Without a formal transition model, each action becomes an exception path with side effects scattered across the app.

**How to avoid:**  
Define the full state machine early, including reset, cancel, skip break, auto-start break, auto-start next work cycle, and long-break rollover after four work sessions. Treat each as an explicit transition with notification, persistence, and analytics consequences.

**Warning signs:**  
- Reset logic deletes state without recording what was interrupted.
- Auto-start settings are checked only in the UI layer.
- Long-break behavior depends on view-specific counters instead of persisted cycle state.

**Phase to address:**  
Phase A and Phase D, verified in Phase E.

## Technical Debt Patterns

Shortcuts that look efficient during MVP work but are likely to poison trust in a productivity tool.

| Shortcut | Immediate Benefit | Long-term Cost | When Acceptable |
|----------|-------------------|----------------|-----------------|
| Drive the timer from a repeating UI tick | Fastest path to a visible countdown | Drift, sleep/wake bugs, inconsistent history | Never |
| Persist only completed sessions | Minimal schema and simpler history screen | No crash recovery, no interrupted-session semantics, poor analytics | Never |
| Allow many tasks per session without a written allocation rule | Flexible UI now | Unreliable per-task metrics and user confusion | Never |
| Duplicate timer state in menu bar and main window view models | Faster local implementation | Cross-surface desync and bug-prone fixes | Never |
| Store precomputed dashboard totals without a recomputation path | Fast dashboard rendering | Metric drift and hard-to-repair corruption | Only if source events remain canonical and rebuild tooling exists |
| Treat notification permission as a setup checkbox | Simpler onboarding | Silent failures and broken trust when alerts never arrive | Never |

## Integration Gotchas

For this app, "integration" is mostly macOS system behavior rather than third-party services.

| Integration | Common Mistake | Correct Approach |
|-------------|----------------|------------------|
| `UNUserNotificationCenter` | Schedule alerts once and forget to cancel or replace them when timer state changes | Key notifications by session ID and timer phase, and reconcile pending notifications on every relevant transition |
| App lifecycle and relaunch | Assume the main window staying open is equivalent to app state durability | Restore from persisted session state and rehydrate all surfaces from the same source |
| Menu bar item | Use custom one-off commands that bypass the main state layer | Route menu bar actions through the same start/pause/reset/skip APIs as the main app |
| System sleep/wake | Ignore wake events because the timer "keeps counting" | Reconcile elapsed time explicitly on wake and decide how interrupted sessions should resolve |
| Local sounds and alerts | Assume sound playback equals notification success | Treat sound as optional feedback layered on top of core timer completion state |

## Performance Traps

The expected scale is one local user, but history and analytics can still become sluggish if modeled poorly.

| Trap | Symptoms | Prevention | When It Breaks |
|------|----------|------------|----------------|
| Recompute all dashboard metrics on every second-level timer tick | CPU usage rises during active sessions and the app feels noisy | Decouple live timer rendering from analytics queries; refresh analytics on meaningful data changes only | Noticeable once history reaches hundreds to low thousands of sessions |
| Reload full session history for every sidebar navigation | Lag entering Dashboard, History, or Statistics | Add targeted queries and lightweight summaries; paginate or window long history views | Usually visible after a few thousand session rows |
| Store denormalized per-task totals without reconciliation tooling | Stats become fast but eventually disagree with history | Keep immutable source events and periodic verification or rebuild logic | Breaks as soon as task edits, reassignment, or interruptions occur |
| Excessive menu bar refresh frequency | Battery drain and visual jitter | Update the menu bar on a sane cadence and from authoritative state changes | Visible immediately on laptops during long workdays |

## Security Mistakes

The app is local-first, so privacy and data exposure matter more than account compromise.

| Mistake | Risk | Prevention |
|---------|------|------------|
| Exposing task titles in notifications without considering privacy | Sensitive work items appear on screen unexpectedly | Make notification content configurable and keep alerts discreet by default |
| Logging task names and session metadata too broadly in debug or analytics output | Local privacy leak and noisy support diagnostics | Separate operational logs from product analytics and avoid storing sensitive task text unless necessary |
| Adding analytics later without explicit local-only or consent rules | The app drifts away from its offline-first promise | Decide early whether analytics are entirely local in v1 and document any future telemetry boundary clearly |

## UX Pitfalls

| Pitfall | User Impact | Better Approach |
|---------|-------------|-----------------|
| Timer looks precise but hides interrupted or canceled states | Users think their tracked time is more trustworthy than it is | Show clear session outcomes and recovery prompts after abnormal interruptions |
| Multi-task selection is allowed without explaining attribution | Per-task stats feel random or dishonest | Explain the rule in the UI and keep attribution consistent everywhere |
| Menu bar controls feel different from main app controls | Users avoid one surface because it seems less reliable | Make behavior identical across surfaces and document only one mental model |
| Notification failures are silent | Users miss breaks or work restarts and blame the app | Surface permission status and provide an in-app fallback indicator |
| History shows only successful completions | Users cannot understand why totals changed after resets or interruptions | Include interrupted, canceled, and skipped outcomes where they matter |

## "Looks Done But Isn't" Checklist

- [ ] **Timer Engine:** Sleep, wake, manual clock change, and app relaunch all preserve correct remaining time and terminal outcome.
- [ ] **Notifications:** Denied permission, revoked permission, skipped breaks, and reset flows were all tested with pending alerts cleared correctly.
- [ ] **Menu Bar:** Start, pause, reset, and reopen behavior exactly match the main timer view with no duplicate logic.
- [ ] **Persistence:** In-progress sessions survive crash or force-quit and recover into a clearly defined state.
- [ ] **Analytics:** Dashboard totals can be recomputed from source records and match task-level and history views.
- [ ] **Task Attribution:** Multi-task sessions use one written allocation rule that is stored with the session and reflected consistently in all metrics.
- [ ] **Cycle Logic:** Fixed four-cycle rollover, long break transition, and auto-start combinations are covered by tests.

## Recovery Strategies

| Pitfall | Recovery Cost | Recovery Steps |
|---------|---------------|----------------|
| Timer drift after sleep/wake | HIGH | Freeze new feature work, instrument elapsed-time calculations, add deterministic sleep/wake tests, and migrate active-session logic to authoritative timestamps |
| Desynced menu bar vs. main app state | MEDIUM | Remove duplicate local state, centralize state transitions, and regression-test each control surface against the same scenarios |
| Stale or missing notifications | MEDIUM | Add notification reconciliation on every session transition, expose permission status, and run manual QA for denied and revoked states |
| Missing or corrupt in-progress session data after crash | HIGH | Introduce durable session state writes, write migration or repair logic for incomplete rows, and define recovery prompts on launch |
| Analytics drift from mutable task data | HIGH | Rebuild metrics from immutable source events, backfill attribution snapshots where possible, and add cross-view reconciliation tests |
| Ambiguous multi-task attribution | HIGH | Freeze the UI behavior, choose one rule, migrate existing records to an explicit attribution model, and annotate any historical uncertainty |

## Pitfall-to-Phase Mapping

| Pitfall | Prevention Phase | Verification |
|---------|------------------|--------------|
| Timer drift from wall-clock assumptions | Phase A | Automated tests simulate pause/resume and sleep/wake; relaunch preserves the same remaining time calculation |
| Multiple timer authorities create state divergence | Phase A | Menu bar and main window issue the same commands and reflect the same state immediately |
| Notification logic assumes delivery instead of verifying it | Phase C | Pending notifications always match the active session; denied permission has a visible fallback state |
| Menu bar integration becomes a separate app instead of a surface | Phase C | Relaunch, reopen, and background workflows behave identically regardless of entry point |
| Session persistence records outcomes too late | Phase B | Force-quit mid-session and relaunch produces a defined recoverable outcome with intact history |
| Analytics are computed from mutable UI state instead of stable events | Phase D | Metrics remain stable after task edits and can be regenerated from raw records |
| Multi-task attribution rules stay ambiguous too long | Phase D | Every session record stores explicit attribution and every metric uses the same allocation rule |
| Reset, skip, and auto-start semantics are not first-class transitions | Phase A | Full state-machine tests cover reset, skip, auto-start, and long-break rollover without duplicate sessions or stale notifications |

## Sources

- Project constraints and open questions from `.planning/PROJECT.md`
- Native macOS app development experience with lifecycle, menu bar, and notification edge cases
- Common timer and productivity-app failure modes observed in local-first desktop products

---
*Pitfalls research for: native macOS Pomodoro and productivity apps*
*Researched: 2026-03-06*
