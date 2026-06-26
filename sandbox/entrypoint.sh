#!/usr/bin/env bash
set -euo pipefail

# pipx 1.x stores venvs under ~/.local/share/pipx (XDG layout), but the
# ChromaDB systemd unit shipped by crewrig hardcodes the older ~/.local/pipx
# path. Bridge them with a symlink so the unit's ExecStart resolves (combined
# with the systemctl shim's interpreter-drop, the daemon then starts on the
# venv's python regardless of the unit's hardcoded python3.13).
if [ -d "$HOME/.local/share/pipx" ] && [ ! -e "$HOME/.local/pipx" ]; then
  ln -s "$HOME/.local/share/pipx" "$HOME/.local/pipx"
fi

# Auto-start the MemPalace ChromaDB daemon on each session. A container has no
# init system, so the daemon started during setup does not survive across
# `docker run` invocations — without this, the MemPalace MCP server has nothing
# to talk to at 127.0.0.1:8001 and friction tags / memory writes fail. Only
# fires when MemPalace was actually set up (its unit exists). Non-blocking.
_mp_unit="$HOME/.config/systemd/user/mempalace-chroma-server.service"
if [ -f "$_mp_unit" ] && ! curl -sf http://127.0.0.1:8001/api/v2/heartbeat >/dev/null 2>&1; then
  echo ">> Starting MemPalace ChromaDB daemon (127.0.0.1:8001)..."
  systemctl --user start mempalace-chroma-server >/dev/null 2>&1 || \
    echo ">> Warning: could not start the ChromaDB daemon; run 'systemctl --user start mempalace-chroma-server'." >&2
fi

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
