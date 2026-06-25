#!/usr/bin/env bash
#
# Launch the CrewRig adoption-fork sandbox.
#
# Builds the image (once, cached) and drops you into an isolated Ubuntu
# container with Node, Claude Code, and the full toolchain. The fork is
# bind-mounted at /workspace, mirroring this repository both ways. The
# container's ~/.claude lives in a dedicated Docker volume, so nothing here
# pollutes your personal Claude Code / CrewRig installation on the host.
#
# Usage:
#   sandbox/run.sh                 # build if needed, then open an interactive shell
#   sandbox/run.sh --rebuild       # force a fresh image build
#   sandbox/run.sh claude          # run a command directly instead of a shell
#   sandbox/run.sh -- claude --help
#
# Auth: if ANTHROPIC_API_KEY is set in your host environment it is forwarded;
# otherwise run `claude` inside the container and /login (persists in the volume).

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

# --- Forward the API key only if present ---
ENV_ARGS=()
if [[ -n "${ANTHROPIC_API_KEY:-}" ]]; then
  ENV_ARGS+=(-e "ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY}")
fi

# Default command: an interactive shell.
if [[ ${#ARGS[@]} -eq 0 ]]; then
  ARGS=(bash)
fi

echo ">> Entering sandbox (fork mounted at /workspace, HOME isolated in volume '$VOLUME')"
exec "$ENGINE" run --rm -it \
  -v "$REPO_DIR":/workspace \
  -v "$VOLUME":/home/dev \
  -w /workspace \
  "${ENV_ARGS[@]}" \
  "$IMAGE" "${ARGS[@]}"
