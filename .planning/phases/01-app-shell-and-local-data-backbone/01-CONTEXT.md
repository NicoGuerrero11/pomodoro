# Phase 1: App Shell and Local Data Backbone - Context

**Gathered:** 2026-03-06
**Status:** Ready for planning

<domain>
## Phase Boundary

Deliver the first launchable macOS app shell with local-first storage, Dashboard as the landing page, and sidebar navigation for the full v1 section set. This phase establishes the structure and first-run experience of the app, not the deeper timer, analytics, or task capabilities that land in later phases.

</domain>

<decisions>
## Implementation Decisions

### Dashboard first impression
- The landing Dashboard should feel timer-first rather than analytics-first.
- The Dashboard should use a balanced layout: clear primary focus area plus a few supporting cards, without feeling sparse or crowded.
- When there is no user data yet, show honest empty cards rather than fake preview metrics.
- The main Dashboard action should guide the user to create the first task before deeper usage.

### Empty-state guidance
- First-run copy should be calm and direct, not hype-driven or overly chatty.
- The empty Dashboard should include a short checklist that helps the user get started.
- The app should start with no sample data; all content should reflect the user’s real activity.
- Sidebar sections should still open as real pages with concise explanations of what will appear there over time.

### Navigation shell
- The shell should feel Mac-native, using a standard desktop sidebar with icons and labels.
- Sidebar sizing should follow the normal macOS collapse/show behavior rather than inventing a custom navigation pattern.
- Settings should live as a regular sidebar section inside the shell, not as a separate settings window in Phase 1.
- Unpopulated sections should use quiet explanatory copy rather than teaser states or silence.

### Claude's Discretion
- Exact Dashboard card composition and spacing, as long as it stays timer-first and balanced.
- Exact wording of the checklist and empty-state helper copy, as long as it stays calm and direct.
- Exact icon choices and visual styling details within a restrained native macOS feel.
- Main-window behavior details not explicitly discussed, using sensible native defaults unless later planning finds a reason to surface a choice.

</decisions>

<specifics>
## Specific Ideas

- The first impression should make the app feel immediately ready for focused work, not like a blank analytics tool.
- The product should remain honest on day one: no fake data, no inflated preview states, no hidden sections.

</specifics>

<code_context>
## Existing Code Insights

### Reusable Assets
- None yet — there is no existing app codebase to reuse in this phase.

### Established Patterns
- None yet — Phase 1 will establish the initial app shell, navigation, persistence boundary, and first-run UI patterns.

### Integration Points
- New work will create the main macOS app entry, sidebar navigation shell, local persistence container, and first-launch Dashboard flow that later phases will build on.

</code_context>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope.

</deferred>

---
*Phase: 01-app-shell-and-local-data-backbone*
*Context gathered: 2026-03-06*
