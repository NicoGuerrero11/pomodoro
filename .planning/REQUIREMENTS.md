# Requirements: Pomodoro Mac

**Defined:** 2026-03-06
**Core Value:** Every Pomodoro session should clearly connect focused time to concrete task progress.

## v1 Requirements

### Timer and Cycles

- [ ] **TIME-01**: User can start a focus session using one of the allowed work durations: 25, 30, 45, 50, or 60 minutes.
- [ ] **TIME-02**: User can pause and resume an active focus or break session without losing correct remaining time.
- [ ] **TIME-03**: User can reset the current session and the app records the interruption consistently in local history.
- [ ] **TIME-04**: App enforces the fixed Pomodoro sequence of four focus sessions, three short breaks, and one long break before repeating.
- [ ] **TIME-05**: User can choose whether breaks start automatically or manually after a focus session ends.
- [ ] **TIME-06**: User can choose whether the next focus session starts automatically or manually after a break ends.
- [ ] **TIME-07**: User can run a Pomodoro session even when no task is selected.

### Notifications and Native Controls

- [ ] **NOTF-01**: User receives a discreet macOS notification when a focus session or break ends.
- [ ] **NOTF-02**: User hears an end-of-cycle sound when a focus session or break completes.
- [ ] **NOTF-03**: User receives a one-minute-remaining alert during a break.
- [ ] **NOTF-04**: User can view the active timer state and basic controls from the macOS menu bar.

### Tasks

- [ ] **TASK-01**: User can create a task with title, description, and priority.
- [ ] **TASK-02**: User can edit a task’s title, description, and priority after creation.
- [ ] **TASK-03**: User can view tasks ordered so higher-priority pending tasks appear before lower-priority tasks.
- [ ] **TASK-04**: User can mark a task as completed and the completion is reflected in metrics and history.
- [ ] **TASK-05**: User can associate zero, one, or multiple tasks to a focus session before starting it.
- [ ] **TASK-06**: User can view accumulated focus time and completed Pomodoro count for each task.

### Dashboard and Statistics

- [ ] **DASH-01**: User lands on a general dashboard when opening the app.
- [ ] **DASH-02**: User can view completed Pomodoros per day.
- [ ] **DASH-03**: User can view total focused time and completed tasks from the dashboard.
- [ ] **DASH-04**: User can view which task has the most recorded focus time.
- [ ] **DASH-05**: User can view a productive-day streak based on recorded completed work days.
- [ ] **DASH-06**: User can view charts or visual summaries showing recurring productivity patterns, including peak focus hours.

### History

- [ ] **HIST-01**: User can browse persisted history of focus sessions, breaks, and related task outcomes.
- [ ] **HIST-02**: User can filter history by day.
- [ ] **HIST-03**: User can filter history by week.
- [ ] **HIST-04**: User can filter history by task.
- [ ] **HIST-05**: User can filter history by custom date range.

### Settings, Persistence, and Experience

- [ ] **CONF-01**: User can configure short-break duration using only the allowed values: 5, 10, or 15 minutes.
- [ ] **CONF-02**: User can configure long-break duration using only the allowed values: 20, 25, or 30 minutes.
- [ ] **CONF-03**: User’s timer settings, tasks, completed tasks, session history, and productivity data persist locally across app restarts.
- [ ] **CONF-04**: User can use the full v1 app without internet connectivity.
- [ ] **CONF-05**: User can navigate the app through sidebar sections for Dashboard, Timer, Tasks, Statistics, History, and Settings.
- [ ] **CONF-06**: User can use the app in both light mode and dark mode.
- [ ] **CONF-07**: User sees a clean, distraction-light timer experience during an active Pomodoro session.

## v2 Requirements

### Gamification

- **GAM-01**: User receives visual rewards or incentives for completing Pomodoro sessions.
- **GAM-02**: User receives rewards tied to completing tasks and maintaining continuity.

### Sync and Expansion

- **SYNC-01**: User can sync data or use online capabilities across devices.
- **WIDG-01**: User can access timer status through widgets or other live-status surfaces beyond the menu bar.
- **RPT-01**: User can export reports or productivity data in formats such as PDF or CSV.
- **TASK-07**: User can organize work with richer task states or subtasks beyond pending/completed.

## Out of Scope

| Feature | Reason |
|---------|--------|
| User accounts and login | First release is personal-use, local-first, and does not need identity management |
| Arbitrary Pomodoro cycle counts | Product explicitly fixes the cycle count at four |
| Subtasks in v1 | Adds task-management complexity before the core timer-task loop is validated |
| Full project-management features such as projects, boards, or tags | Would broaden the product beyond its first-release purpose |
| Cloud sync or collaboration in v1 | Conflicts with offline-first scope and adds unnecessary infrastructure |
| Report export in v1 | Analytics should stabilize in-app before export formats are designed |
| Gamification in v1 | Deferred until the core experience is proven useful |

## Traceability

Which phases cover which requirements. Updated during roadmap creation.

| Requirement | Phase | Status |
|-------------|-------|--------|

**Coverage:**
- v1 requirements: 35 total
- Mapped to phases: 0
- Unmapped: 35 ⚠️

---
*Requirements defined: 2026-03-06*
*Last updated: 2026-03-06 after initial definition*
