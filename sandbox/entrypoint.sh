#!/usr/bin/env bash
set -euo pipefail

cat <<'BANNER'
────────────────────────────────────────────────────────────────────────────
 CrewRig adoption fork — sandbox (ACME Corp)
────────────────────────────────────────────────────────────────────────────
 The fork is bind-mounted at /workspace (mirrors your host directory).
 Your ~/.claude here lives in an isolated Docker volume — your personal
 installation on the host is NEVER touched.

 Useful moves:
   bash scripts/build-components.sh            # (Step 5) compile CLI outputs
   bash scripts/setup-claude-interactive.sh    # (Step 6) deploy rules into THIS sandbox's ~/.claude
   claude                                      # drive the fork with Claude Code
   npm ci                                      # (optional) install JS workspace deps

 Auth: export ANTHROPIC_API_KEY before launching, or run `claude` and /login
 (the credential persists in the sandbox volume across runs).
────────────────────────────────────────────────────────────────────────────
BANNER

exec "$@"
