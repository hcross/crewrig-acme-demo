# tests/e2e/lib/expand.sh — shared mount-string token expander.
#
# Sourced by `tests/e2e/run.sh` (the runner) and by scenario `run.sh`
# files via `${E2E_LIB_DIR}/expand.sh`. Provides the single canonical
# `expand_mount` implementation so the runner's mount expansion and
# the per-scenario mount expansion cannot drift (which they did,
# silently, before #148 Decision 5 Revision 2 — the runner gained
# `${HOME}` support and the scenario script did not, breaking the
# layered-context probe under gemini).
#
# Supported tokens:
#   ${CREWRIG_E2E_HOME} — bundle root. The caller MUST export
#                         E2E_CREWRIG_E2E_HOME before invoking
#                         `expand_mount`; the runner does this in its
#                         child-env block, and the scenarios receive it
#                         the same way.
#   ${HOME}              — host user home. Taken from the caller's shell
#                          environment.
#
# Maintainer note (CONFIG vs LOGIC):
#   • Adding another token to the substitution chain below is a CONFIG
#     edit — extend the chain, document the token, ship it. In scope
#     for any feature PR that needs a new mount-string variable.
#   • Changes to the parsing model (e.g. nested templates, defaults,
#     fallback expressions, conditional expansion) are LOGIC edits.
#     They cross the #149 (e2e runner cleanup) seam and require
#     architect re-engagement — do not slip them in alongside a
#     feature PR.

expand_mount() {
  local raw="$1"
  : "${E2E_CREWRIG_E2E_HOME:?expand_mount: E2E_CREWRIG_E2E_HOME must be exported by the caller}"
  # Plain string substitutions — guard against re-expansion by the shell.
  local expanded="${raw//\$\{CREWRIG_E2E_HOME\}/$E2E_CREWRIG_E2E_HOME}"
  expanded="${expanded//\$\{HOME\}/$HOME}"
  printf '%s\n' "$expanded"
}
