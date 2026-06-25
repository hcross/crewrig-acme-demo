#!/usr/bin/env bash
set -euo pipefail

cat <<'BANNER'
────────────────────────────────────────────────────────────────────────────
 CrewRig adoption fork — sandbox (ACME Corp)
────────────────────────────────────────────────────────────────────────────
 Dev tree under /workspace:
   crewrig-acme/             the fork — bind-mounted, mirrors your host dir
   games/android/2048-android   sample native Android game (fresh git repo)
   games/web/hextris            sample HTML5 web game (fresh git repo)

 Your ~/.claude and gh config here live in an isolated Docker volume — your
 personal installations on the host are NEVER touched.

 Useful moves:
   cd crewrig-acme                             # enter the fork
   bash scripts/build-components.sh            # (Step 5) compile CLI outputs
   bash scripts/setup-claude-interactive.sh    # (Step 6) deploy rules into THIS sandbox's ~/.claude
   claude                                      # drive the fork with Claude Code

 Auth:
   - Claude Code: export ANTHROPIC_API_KEY before launching, or run `claude` + /login
   - gh: export GH_TOKEN before launching, or run `gh auth login`
   (both persist in the sandbox volume across runs)
────────────────────────────────────────────────────────────────────────────
BANNER

exec "$@"
