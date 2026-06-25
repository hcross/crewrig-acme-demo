---
name: review
description: "Tool- and stack-agnostic code review. Activate to review a change
  (a diff, a PR, or the working tree) for correctness, clarity, tests, security,
  and convention adherence, and report findings grouped by severity."
type: skill
license: Apache-2.0
metadata:
  provenance:
    canonical: "${CANONICAL_REPO}"
    feedback: "${FEEDBACK_REPO}"
    version: "1.0.0"
claude:
  allowed-tools:
    - Read
    - Grep
    - Glob
    - Bash
  user-invocable: true
---

# Review

A focused, technology-agnostic review of a code change. Works on any stack:
the skill reasons about the diff and the surrounding code, not about a specific
language or framework.

## Scope

Review the change in front of you — a named diff or PR if given, otherwise the
uncommitted working tree. Read enough of the surrounding code to judge the
change in context; do not review the whole repository.

## What to look for

Assess the change across five lenses, in priority order:

1. **Correctness** — does it do what it claims? Hunt for logic errors, broken
   edge cases, off-by-one, null/empty handling, race conditions, and incorrect
   error handling.
2. **Clarity** — is the change readable and maintainable? Flag misleading
   names, dead code, needless complexity, and missing rationale for non-obvious
   choices.
3. **Tests** — is the new behavior covered? Note untested branches and missing
   regression tests for the bug being fixed.
4. **Security** — watch for injection, unvalidated input, secret leakage,
   unsafe deserialization, and broken authn/authz on touched paths.
5. **Conventions** — does it match the surrounding code's idioms and the
   project's stated rules? Match comment density, naming, and structure.

## How to report

Group findings by severity and be specific — cite `file:line` and explain the
*why*, not just the *what*:

- **Blocker** — must fix before merge (correctness or security defect).
- **Major** — should fix (likely bug, missing test for risky path).
- **Minor** — nice to fix (clarity, small convention drift).
- **Nit** — optional, non-blocking.

End with a one-line verdict: **Approve**, **Approve with nits**, or
**Request changes**. Do not manufacture objections to seem thorough; if the
change is clean, say so plainly.
