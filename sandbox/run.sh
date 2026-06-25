#!/usr/bin/env bash
#
# Launch the CrewRig adoption-fork sandbox.
#
# Builds the image (once, cached) and drops you into an isolated Ubuntu
# container with Node, Claude Code, gh, and the full toolchain. The dev tree
# lives under /workspace:
#
#   /workspace/crewrig-acme/   <- this fork, bind-mounted (mirrors the host both ways)
#   /workspace/games/          <- sample Android + web games baked into the image
#
# The container's ~/.claude (and gh config) live in a dedicated Docker volume,
# so nothing here pollutes your personal Claude Code / CrewRig / gh setup.
#
# Usage:
#   sandbox/run.sh                 # build if needed, then open an interactive shell
#   sandbox/run.sh --rebuild       # force a fresh image build
#   sandbox/run.sh claude          # run a command directly instead of a shell
#   sandbox/run.sh -- claude --help
#
# Auth:
#   - Claude Code: ANTHROPIC_API_KEY is forwarded if set; otherwise run `claude`
#     inside and /login (persists in the volume).
#   - gh: GH_TOKEN / GITHUB_TOKEN are forwarded if set; otherwise run
#     `gh auth login` inside (persists in the volume).

set -euo pipefail

IMAGE="crewrig-sandbox:latest"
VOLUME="crewrig-sandbox-home"          # persistent, isolated container HOME
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# --- Pick a container engine (docker or podman) ---
if command -v docker >/dev/null 2>&1; then
  ENGINE=docker
elif command -v podman >/dev/null 2>&1; then
  ENGINE=podman
else
  echo "Error: neither docker nor podman found on PATH." >&2
  exit 1
fi

# --- Parse args ---
REBUILD=false
ARGS=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --rebuild) REBUILD=true; shift ;;
    --) shift; ARGS+=("$@"); break ;;
    *) ARGS+=("$1"); shift ;;
  esac
done

# --- Build the image if missing or on demand ---
if $REBUILD || ! "$ENGINE" image inspect "$IMAGE" >/dev/null 2>&1; then
  echo ">> Building $IMAGE ..."
  "$ENGINE" build -t "$IMAGE" "$SCRIPT_DIR"
fi

# --- Ensure the persistent, isolated HOME volume exists ---
"$ENGINE" volume inspect "$VOLUME" >/dev/null 2>&1 || "$ENGINE" volume create "$VOLUME" >/dev/null

# --- Forward credentials only if present in the host environment ---
ENV_ARGS=()
[[ -n "${ANTHROPIC_API_KEY:-}" ]] && ENV_ARGS+=(-e "ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY}")
[[ -n "${GH_TOKEN:-}" ]]         && ENV_ARGS+=(-e "GH_TOKEN=${GH_TOKEN}")
[[ -n "${GITHUB_TOKEN:-}" ]]     && ENV_ARGS+=(-e "GITHUB_TOKEN=${GITHUB_TOKEN}")

# Default command: an interactive shell.
if [[ ${#ARGS[@]} -eq 0 ]]; then
  ARGS=(bash)
fi

echo ">> Entering sandbox (fork at /workspace/crewrig-acme, HOME isolated in volume '$VOLUME')"
exec "$ENGINE" run --rm -it \
  -v "$REPO_DIR":/workspace/crewrig-acme \
  -v "$VOLUME":/home/dev \
  -w /workspace \
  "${ENV_ARGS[@]}" \
  "$IMAGE" "${ARGS[@]}"
