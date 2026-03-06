# Roadmap: Pomodoro Mac

## Overview

Pomodoro Mac reaches v1 by establishing a native macOS shell and local data backbone first, then layering in task management, a trustworthy timer engine, configurable cycle behavior, native system integrations, task-linked progress, and finally the analytics and history surfaces that make focused time meaningful. The sequence keeps timer correctness, persistence, and attribution ahead of reporting so later metrics reflect stable recorded events instead of UI-only state.

## Phases

**Phase Numbering:**
- Integer phases (1, 2, 3): Planned milestone work
- Decimal phases (2.1, 2.2): Urgent insertions (marked with INSERTED)

Decimal phases appear between their surrounding integers in numeric order.

- [ ] **Phase 1: App Shell and Local Data Backbone** - Establish the native macOS structure, offline-first persistence, and primary navigation.
- [ ] **Phase 2: Task Capture and Prioritization** - Deliver basic task creation, editing, and priority-driven ordering.
- [ ] **Phase 3: Core Focus Timer** - Build the main timer experience with start, pause, reset, and no-task operation.
- [ ] **Phase 4: Cycle Rules and Timing Preferences** - Enforce the fixed Pomodoro sequence and expose allowed timing controls.
- [ ] **Phase 5: Native Alerts and Menu Bar** - Add macOS notifications, sounds, menu bar controls, and appearance support.
- [ ] **Phase 6: Session Linking and Task Progress** - Connect focus sessions to selected tasks and expose per-task progress totals.
- [ ] **Phase 7: Dashboard Core Metrics** - Surface the primary dashboard numbers that summarize completed work.
- [ ] **Phase 8: History and Task Outcomes** - Add persisted history browsing plus task completion outcomes reflected in metrics and history.
- [ ] **Phase 9: Productivity Patterns and Extended Filters** - Finish advanced pattern analytics and the remaining history filters.

## Phase Details

### Phase 1: App Shell and Local Data Backbone
**Goal**: Deliver the first launchable macOS app shell with local-first storage, dashboard landing page, and the full v1 sidebar structure.
**Depends on**: Nothing (first phase)
**Requirements**: [DASH-01, CONF-03, CONF-04, CONF-05]
**Success Criteria** (what must be TRUE):
  1. User lands on the Dashboard when opening the app.
  2. User can navigate sidebar sections for Dashboard, Timer, Tasks, Statistics, History, and Settings.
  3. User data persists locally across app restarts.
  4. User can use the v1 app without internet connectivity.
**Plans**: 3 plans

Plans:
- [ ] 01-01: Create the app scene structure, sidebar shell, and initial dashboard entry flow.
- [ ] 01-02: Define the local persistence container, repositories, and settings storage boundaries.
- [ ] 01-03: Implement offline-safe bootstrapping, seed states, and relaunch recovery foundations.

### Phase 2: Task Capture and Prioritization
**Goal**: Give the user a usable task list with editable task details and priority-based ordering before task-session linkage begins.
**Depends on**: Phase 1
**Requirements**: [TASK-01, TASK-02, TASK-03]
**Success Criteria** (what must be TRUE):
  1. User can create a task with title, description, and priority.
  2. User can edit a task’s title, description, and priority after creation.
  3. User sees pending tasks ordered so higher-priority work appears before lower-priority work.
**Plans**: 2 plans

Plans:
- [ ] 02-01: Build task data models, validation rules, and CRUD flows.
- [ ] 02-02: Ship the tasks list and editor UI with priority-first sorting behavior.

### Phase 3: Core Focus Timer
**Goal**: Deliver the main focus-session experience with reliable control actions and a clean active timer surface.
**Depends on**: Phase 1
**Requirements**: [TIME-01, TIME-02, TIME-03, TIME-07, CONF-07]
**Success Criteria** (what must be TRUE):
  1. User can start a focus session using the allowed work durations.
  2. User can pause and resume an active focus session without losing correct remaining time.
  3. User can reset the current session and the interruption is recorded consistently in local history.
  4. User can run a Pomodoro session even when no task is selected.
  5. User sees a clean, distraction-light timer experience during an active Pomodoro session.
**Plans**: 3 plans

Plans:
- [ ] 03-01: Implement the single timer authority, timestamp-based countdown model, and work-duration presets.
- [ ] 03-02: Build timer controls, active-session UI, and interruption recording.
- [ ] 03-03: Validate relaunch and pause/resume behavior against persisted timer state.

### Phase 4: Cycle Rules and Timing Preferences
**Goal**: Add the fixed four-session Pomodoro flow and all approved timing preferences on top of the working timer.
**Depends on**: Phase 3
**Requirements**: [TIME-04, TIME-05, TIME-06, CONF-01, CONF-02]
**Success Criteria** (what must be TRUE):
  1. App enforces the fixed sequence of four focus sessions, three short breaks, and one long break before repeating.
  2. User can configure short-break duration using only the allowed values.
  3. User can configure long-break duration using only the allowed values.
  4. User can choose whether breaks start automatically or manually after a focus session ends.
  5. User can choose whether the next focus session starts automatically or manually after a break ends.
**Plans**: 2 plans

Plans:
- [ ] 04-01: Implement cycle-state transitions, break scheduling, and sequence tracking.
- [ ] 04-02: Add settings-backed timing preferences and auto-start behaviors to the timer flow.

### Phase 5: Native Alerts and Menu Bar
**Goal**: Project timer state into native macOS surfaces so the app behaves like a real desktop utility.
**Depends on**: Phase 4
**Requirements**: [NOTF-01, NOTF-02, NOTF-03, NOTF-04, CONF-06]
**Success Criteria** (what must be TRUE):
  1. User receives a discreet macOS notification when a focus session or break ends.
  2. User hears an end-of-cycle sound when a focus session or break completes.
  3. User receives a one-minute remaining alert during a break.
  4. User can view the active timer state and basic controls from the macOS menu bar.
  5. User can use the app in both light mode and dark mode.
**Plans**: 2 plans

Plans:
- [ ] 05-01: Integrate system notifications, break warnings, and end-of-cycle sound delivery.
- [ ] 05-02: Build the menu bar surface and verify appearance behavior across light and dark modes.

### Phase 6: Session Linking and Task Progress
**Goal**: Make focus sessions meaningful by letting users associate work with tasks and see per-task accumulation.
**Depends on**: Phase 2, Phase 4
**Requirements**: [TASK-05, TASK-06]
**Success Criteria** (what must be TRUE):
  1. User can associate zero, one, or multiple tasks to a focus session before starting it.
  2. User can view accumulated focus time for each task.
  3. User can view completed Pomodoro count for each task.
**Plans**: 2 plans

Plans:
- [ ] 06-01: Define and persist task-session attribution rules and selection workflows.
- [ ] 06-02: Add per-task progress queries and task-detail surfaces for time and Pomodoro totals.

### Phase 7: Dashboard Core Metrics
**Goal**: Turn stored sessions and task data into the primary dashboard metrics the user checks daily.
**Depends on**: Phase 6
**Requirements**: [DASH-02, DASH-03, DASH-04, DASH-05]
**Success Criteria** (what must be TRUE):
  1. User can view completed Pomodoros per day.
  2. User can view total focused time and completed tasks from the dashboard.
  3. User can view which task has the most recorded focus time.
  4. User can view a productive-day streak based on recorded completed work days.
**Plans**: 2 plans

Plans:
- [ ] 07-01: Build analytics queries for daily Pomodoros, focused time, completed tasks, and streaks.
- [ ] 07-02: Ship the dashboard cards and summaries that present the core metrics clearly.

### Phase 8: History and Task Outcomes
**Goal**: Add trustworthy historical review and make task completion visible in both metrics and recorded outcomes.
**Depends on**: Phase 6, Phase 7
**Requirements**: [TASK-04, HIST-01, HIST-02, HIST-03]
**Success Criteria** (what must be TRUE):
  1. User can mark a task as completed and the completion is reflected in metrics and history.
  2. User can browse persisted history of focus sessions, breaks, and related task outcomes.
  3. User can filter history by day.
  4. User can filter history by week.
**Plans**: 2 plans

Plans:
- [ ] 08-01: Implement task completion workflows and wire them into stored analytics and outcome records.
- [ ] 08-02: Build the history view with persisted event browsing plus day and week filters.

### Phase 9: Productivity Patterns and Extended Filters
**Goal**: Finish the remaining history filters and the richer pattern analytics that reveal recurring productivity behavior.
**Depends on**: Phase 8
**Requirements**: [DASH-06, HIST-04, HIST-05]
**Success Criteria** (what must be TRUE):
  1. User can filter history by task.
  2. User can filter history by custom date range.
  3. User can view charts or visual summaries showing recurring productivity patterns, including peak focus hours.
**Plans**: 2 plans

Plans:
- [ ] 09-01: Extend history queries and UI with task and custom date range filters.
- [ ] 09-02: Build the statistics patterns views, including peak-focus-hour visualizations.

## Progress

**Execution Order:**
Phases execute in numeric order: 1 → 2 → 3 → 4 → 5 → 6 → 7 → 8 → 9

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. App Shell and Local Data Backbone | 0/3 | Not started | - |
| 2. Task Capture and Prioritization | 0/2 | Not started | - |
| 3. Core Focus Timer | 0/3 | Not started | - |
| 4. Cycle Rules and Timing Preferences | 0/2 | Not started | - |
| 5. Native Alerts and Menu Bar | 0/2 | Not started | - |
| 6. Session Linking and Task Progress | 0/2 | Not started | - |
| 7. Dashboard Core Metrics | 0/2 | Not started | - |
| 8. History and Task Outcomes | 0/2 | Not started | - |
| 9. Productivity Patterns and Extended Filters | 0/2 | Not started | - |
