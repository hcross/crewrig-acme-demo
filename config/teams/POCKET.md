# Team Pocket — Mobile Platform

## Mission

Pocket builds and ships ACME's native mobile games for phones. The team owns
the Android and iOS clients and their integration with the shared Spark
gameplay core, targeting buttery-smooth play on mid-range devices and a
warm-start under one second.

## Technology Stack

- **Android:** Kotlin 2.x, Jetpack Compose for menus, native render surface,
  Gradle (Kotlin DSL)
- **iOS:** Swift, SwiftUI for menus, Metal-backed render surface
- **Shared core:** the Spark gameplay core consumed via native bindings
- **Testing:** JUnit + Espresso + Macrobenchmark (Android), XCTest (iOS),
  device-farm runs on a matrix of mid-range phones
- **Monitoring:** Firebase Crashlytics, custom frame-time and battery telemetry

## Development Practices

- Hard 60 fps budget and sub-1s warm start; render-path changes ship with
  before/after profiler captures attached to the PR.
- Platform clients stay thin — gameplay logic lives in Spark, not in the
  Android/iOS shells.
- Minimal permissions and no undeclared data collection; every release passes a
  store-policy and privacy check.
- Release trains gated on the device-farm performance matrix.

## Rituals

Scrum with two-week sprints. Sprint planning Monday, daily standup (15 min),
demo and retrospective every other Friday.

## Collaboration Norms

- Branch naming: `feat/`, `fix/`, `perf/` prefixes.
- Gitmoji commits. PRs require one approval plus a passing performance check;
  two approvals when the Spark core is touched.
- Store releases (Google Play / App Store) coordinated with live-ops before
  rollout.

## Documentation

- **Confluence:** Space "Pocket Mobile" for client architecture, release
  runbooks, and the device-support matrix.
- **Doc-as-code:** Per-platform README and ADRs versioned with the client code.

## Issue Tracking

- Jira project prefix: **`PKT-`**
- Stories tied to titles and platform features; performance and crash
  regressions filed as release-blocking bugs.

## Key Contacts

- **Tech Lead:** pocket-lead@acme.example
- **Slack:** #team-pocket
