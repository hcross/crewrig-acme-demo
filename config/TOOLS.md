# Tools and MCP Server Guidelines

<!-- Framework-wide instructions (three-tier memory architecture, MemPalace
     protocol, harness engineering loop, Sequential Thinking, Obsidian access
     model) are in the core rules file deployed at priority 60. This file,
     deployed at priority 65, carries ACME Corp-specific additions only. -->

## Tooling Preferences

- **Editors:** Android Studio (mobile), VS Code (web and shared tooling).
- **Terminal:** zsh + oh-my-zsh. Always available: `gradle`, `adb`, `pnpm`,
  `acme` (internal studio CLI for scaffolding titles and running the Spark
  core locally).
- **Communication:** Slack — `#studio-announce` for broad announcements, one
  channel per team (`#team-arcade`, `#team-pocket`).
- **Game tooling:** Spark engine CLI for local playtesting; Chrome DevTools
  and Android Studio Profiler for the mandatory frame-time checks.

## MCP Server Declarations

- `jira` — ACME issue tracker. Read issue details and post progress comments;
  do NOT create or close issues without explicit user instruction.
- `figma` — read-only access to game UI mockups and asset specs. Never write.

If a server is not listed here, assume only the framework defaults
(MemPalace, SequentialThinking, GitHub) are available.

## Workflow Preferences

- Every gameplay-affecting change ships behind a live-ops flag so it can be
  tuned or rolled back without a redeploy.
- A frame-time / cold-start measurement is attached to any PR that touches the
  render loop, asset loading, or the Spark core.
- Squash before opening a PR; PRs require one approval, two when the Spark
  shared core is touched.
