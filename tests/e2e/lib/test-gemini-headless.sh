#!/usr/bin/env bash
# tests/e2e/lib/test-gemini-headless.sh — regression test for issue #139.
#
# Failure modes under test:
#
#   MODE A — oauth-personal (real settings.json): gemini -p makes an API call,
#   delivers a response, then blocks indefinitely because the BidiGenerateContent
#   WebSocket (wss://generativelanguage.googleapis.com) remains open after the
#   single-turn response. The container never exits.
#
#   MODE B — empty settings (PR #137 workaround, settings-headless.json={}):
#   gemini -p exits immediately with code 41 ("Auth method not configured")
#   without making any API call. No answer.txt is written. Scenario assertions
#   that check for answer.txt therefore fail even though the container exits.
#
# This test locks in MODE B as the observed broken state (post-PR-#137) so
# the developer can validate the fix: pre-fetched OAuth token passed via
# GOOGLE_CLOUD_ACCESS_TOKEN + GOOGLE_GENAI_USE_GCA=true, wrapped by timeout.
#
# Run standalone: bash tests/e2e/lib/test-gemini-headless.sh
# TAP output: ok N - ... / not ok N - ...

set -uo pipefail

GEMINI_IMAGE="${GEMINI_IMAGE:-crewrig/e2e-gemini:latest}"
GEMINI_DIR="${CREWRIG_E2E_HOME:-$HOME/.crewrig-e2e}/gemini"
HEADLESS_SETTINGS="${GEMINI_DIR}/settings-headless.json"

TAP_INDEX=0
TAP_NOK=0

emit() {
  TAP_INDEX=$((TAP_INDEX + 1))
  case "$1" in
    ok)     printf 'ok %d - %s\n'     "$TAP_INDEX" "$2" ;;
    not_ok) printf 'not ok %d - %s\n' "$TAP_INDEX" "$2"; TAP_NOK=$((TAP_NOK + 1)) ;;
  esac
}

# --------------------------------------------------------------------------
# Preconditions
# --------------------------------------------------------------------------

if ! command -v docker >/dev/null 2>&1; then
  printf '1..0 # SKIP docker not found on PATH\n'
  exit 78
fi

if ! docker image inspect "$GEMINI_IMAGE" >/dev/null 2>&1; then
  printf '1..0 # SKIP image %s not present locally\n' "$GEMINI_IMAGE"
  exit 78
fi

if [[ ! -f "$HEADLESS_SETTINGS" ]]; then
  printf '1..0 # SKIP settings-headless.json not found at %s\n' "$HEADLESS_SETTINGS"
  exit 78
fi

# --------------------------------------------------------------------------
# Test 1 — MODE B: empty settings exits non-zero (auth fails, no API call).
# Expected post-PR-#137: exit 41 with "Auth method" in stderr.
# --------------------------------------------------------------------------

WORK_DIR="$(mktemp -d)"
trap 'rm -rf "$WORK_DIR"' EXIT

docker run --rm \
  -v "${GEMINI_DIR}:/home/agent/.gemini:ro" \
  -v "${HEADLESS_SETTINGS}:/home/agent/.gemini/settings.json:ro" \
  -v "${WORK_DIR}:/out" \
  "$GEMINI_IMAGE" \
  gemini -p "Write the single word READY to /out/answer.txt and print it." \
  >"${WORK_DIR}/stdout.txt" 2>"${WORK_DIR}/stderr.txt"
actual_exit=$?

# Auth failure must surface as non-zero exit.
if (( actual_exit != 0 )); then
  emit ok "MODE B: empty settings.json causes non-zero exit (got ${actual_exit})"
else
  emit not_ok "MODE B: expected non-zero exit with empty settings.json, got 0"
fi

# Auth error message must appear — confirms no API call was attempted.
if grep -qiE "Auth method|authentication|credentials" \
     "${WORK_DIR}/stderr.txt" "${WORK_DIR}/stdout.txt" 2>/dev/null; then
  emit ok "MODE B: auth-failure message present in output"
else
  emit not_ok "MODE B: auth-failure message absent — output was: $(cat "${WORK_DIR}/stdout.txt" "${WORK_DIR}/stderr.txt" 2>/dev/null | head -c 200)"
fi

# --------------------------------------------------------------------------
# Test 2 — answer.txt MUST be written (the core regression assertion).
#
# This assertion FAILS until the fix is applied. After the fix:
#   - GOOGLE_CLOUD_ACCESS_TOKEN is pre-fetched on the host
#   - GOOGLE_GENAI_USE_GCA=true is passed into the container
#   - gemini -p is wrapped with `timeout 120`
#   - exit 124 (timeout) is treated as success when answer.txt is non-empty
#
# Until those conditions are met, MODE B exits 41 without writing answer.txt,
# and this assertion is the red line that proves the bug is present.
# --------------------------------------------------------------------------

if [[ -s "${WORK_DIR}/answer.txt" ]]; then
  emit ok "answer.txt written and non-empty (fix is in place)"
else
  emit not_ok "answer.txt absent — gemini exited ${actual_exit} without making an API call (issue #139 unfixed)"
fi

printf '1..%d\n' "$TAP_INDEX"

if (( TAP_NOK > 0 )); then
  exit 1
fi
exit 0
