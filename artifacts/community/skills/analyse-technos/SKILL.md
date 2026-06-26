---
name: analyse-technos
description: "Scan a project and produce a grouped technology inventory: languages,
  frameworks, build tooling, CI/CD, and infrastructure. Reads README.md and AGENTS.md
  first, then walks the directory tree to infer the full stack."
type: skill
metadata:
  provenance:
    canonical: "${FEEDBACK_REPO}"
    feedback: "${FEEDBACK_REPO}"
    version: "1.0.2"
claude:
  allowed-tools:
    - Read
    - Bash
  user-invocable: true
---

# Analyse Technos

Produce a concise, grouped technology inventory for the current project.
The output is structured for human review and suitable for onboarding,
architecture documentation, or dependency audits.

## When to activate

- The user asks which technologies a project uses, or requests a stack overview.
- An onboarding or architecture document is being drafted and a technology
  summary is needed.
- A dependency audit is starting and the scope of the stack must be established.

## Procedure

### Step 1 — Read project-level declarations

Read these files in order, if they exist:

1. `README.md` — usually declares the stack explicitly; extract any technology
   list, badge, or "built with" section.
2. `AGENTS.md` (and any included files such as `AGENTS.org.md`) — contains the
   *Technology Stack* section used by agents; treat it as authoritative for the
   build/test/runtime split.
3. `package.json`, `pyproject.toml`, `Cargo.toml`, `build.gradle.kts`,
   `build.gradle`, `pom.xml`, `go.mod`, `composer.json`, or any other first-class
   manifest at the repo root — extract declared dependencies and runtime.

### Step 2 — Walk the directory tree

Run a fast, non-intrusive sweep to collect signals the manifest files may not
capture:

```bash
# List top-level files and directories
find . -maxdepth 2 -not -path './.git/*' -not -path './node_modules/*' \
       -not -path './.worktrees/*' | sort
```

Look for:

- **Configuration files** that imply tooling: `.eslintrc*`, `prettier.config.*`,
  `tailwind.config.*`, `vite.config.*`, `webpack.config.*`, `jest.config.*`,
  `vitest.config.*`, `playwright.config.*`, `pyproject.toml`, `ruff.toml`,
  `mypy.ini`, `Makefile`, `Taskfile.yml`, `justfile`.
- **CI/CD pipelines**: `.github/workflows/*.yml`, `.gitlab-ci.yml`,
  `.circleci/config.yml`, `Jenkinsfile`, `azure-pipelines.yml`.
- **Infrastructure-as-code**: `terraform/`, `*.tf`, `docker-compose*.yml`,
  `Dockerfile`, `k8s/`, `helm/`, `*.yaml` under `infra/` or `deploy/`.
- **Language indicators**: dominant file extensions (`.ts`, `.tsx`, `.py`,
  `.kt`, `.rs`, `.go`, `.java`, …).
- **Lock files**: `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`,
  `poetry.lock`, `Cargo.lock`, `go.sum` — confirm the package manager.

### Step 3 — Compose the inventory

Group findings into five categories. Omit any category where no evidence was
found — do not invent or guess.

#### 1. Languages

List each programming language detected with its primary role in the project
(e.g. "TypeScript — portal frontend", "Kotlin — Android client").

#### 2. Frameworks & Libraries

List significant frameworks and libraries. Distinguish runtime dependencies
from dev/test-only ones when the distinction is clear. Mention the version
only if it is unusual or security-relevant.

#### 3. Build & Package Management

Build systems, task runners, bundlers, and package managers (e.g. Gradle/Kotlin
DSL, Vite, esbuild, pnpm, Taskfile).

#### 4. CI/CD

Pipeline tooling and hosting (e.g. GitHub Actions, GitLab CI, CircleCI). List
the number of workflow files and their apparent purpose when legible.

#### 5. Infrastructure & Deployment

Container runtimes, orchestration, cloud providers, CDN, and IaC tooling
(e.g. Docker, Kubernetes, Terraform, Cloudflare). Leave empty if the project
has no infrastructure layer (e.g. a pure library).

### Step 4 — Present the report

Output the grouped inventory as a Markdown section titled
`## Technology Inventory`. Lead each category with a bold heading. Use a
bullet list per category; one bullet per technology. Keep each bullet to one
line: `**Name** — role or brief note`.

Append a `### Sources` subsection listing the files that contributed evidence,
so the reader can verify the inventory without re-running the scan.

Produce **all headings, bullet labels, and prose in the user's active
interaction language** as defined by the session's language rule (e.g. the
global idiomatic-French instruction). Technology names, file paths, and code
identifiers are never translated.

## Output format

> Produce this report in the user's active interaction language. The template
> below uses English as an illustration only — headings and prose must match
> the session language.

```markdown
## Technology Inventory

**Languages**
- **TypeScript** — portal frontend and tooling
- **Kotlin** — Android client

**Frameworks & Libraries**
- **React 19** — portal UI (runtime)
- **Jetpack Compose** — Android UI/menus (runtime)
- **Vitest** — unit testing (dev)
- **Playwright** — E2E testing (dev)

**Build & Package Management**
- **Vite / esbuild** — portal bundler
- **Gradle (Kotlin DSL)** — Android build system
- **pnpm** — Node.js package manager
- **Taskfile** — task runner

**CI/CD**
- **GitHub Actions** — 3 workflows (build, test, deploy)

**Infrastructure & Deployment**
- **Cloudflare CDN** — portal delivery

### Sources
- `README.md`
- `AGENTS.md`
- `package.json`
- `.github/workflows/`
```

## Accuracy constraints

- Report only what is **evidenced** by files present in the repository.
  Do not infer technologies from the project name, domain, or general
  knowledge unless a file confirms it.
- If a technology appears in a manifest but its scope is unclear (e.g.
  a dependency listed in `package.json` with no other context), note it
  with a `(unconfirmed role)` qualifier rather than omitting it silently.
- If `README.md` and a manifest contradict each other (e.g. README says
  Webpack but `vite.config.ts` is present), report both and flag the
  discrepancy with a one-line note.
