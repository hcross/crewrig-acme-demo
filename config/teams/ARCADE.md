# Team Arcade — Web Platform

## Mission

Arcade builds and ships ACME's instant-play browser games and the Arcade
Portal that hosts them. The team owns the full web surface: from the portal's
landing experience to the in-browser game runtime, with an obsession for
time-to-fun — a game must be playable within two seconds of a cold load.

## Technology Stack

- **Runtime:** TypeScript, HTML5 Canvas / WebGL, WebAudio, the Spark core
  compiled to WebAssembly
- **Portal frontend:** React 19, Vite, Tailwind CSS
- **Build & delivery:** Vite, esbuild, served from a global CDN
- **Testing:** Vitest, Playwright for E2E, automated frame-time capture
- **Monitoring:** Web Vitals via Grafana, Sentry for error tracking

## Development Practices

- Performance budgets enforced in CI: cold-start under 2 s, 60 fps on low-end
  laptops, bundle-size ceilings per title.
- The game loop is allocation-free in steady state; GC pauses are treated as
  bugs.
- Gameplay logic stays in the shared Spark core — the web layer is a thin
  rendering and input shell.
- Accessibility and input parity (keyboard, touch, pointer) tested in every
  user-facing PR.

## Rituals

Scrum with two-week sprints. Sprint planning Monday, daily standup (15 min),
demo and retrospective every other Friday.

## Collaboration Norms

- Branch naming: `feat/`, `fix/`, `perf/` prefixes.
- Gitmoji commits. PRs require one approval plus a passing performance check;
  two approvals when the Spark core is touched.
- Design reviews with UX before any user-facing change.

## Documentation

- **Confluence:** Space "Arcade Web" for portal architecture, runtime design,
  and performance runbooks.
- **Doc-as-code:** Storybook for portal UI components, deployed from main.

## Issue Tracking

- Jira project prefix: **`ARC-`**
- Stories tied to titles and portal features; performance regressions filed as
  release-blocking bugs.

## Key Contacts

- **Tech Lead:** arcade-lead@acme.example
- **Slack:** #team-arcade
