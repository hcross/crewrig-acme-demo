#!/usr/bin/env bash
#
# Minimal `systemctl` shim for the CrewRig sandbox.
#
# A container has no init system, so the real systemctl is absent and
# crewrig's MemPalace setup (scripts/lib/common.sh -> install_chroma_daemon)
# aborts at `systemctl --user enable --now mempalace-chroma-server`.
#
# This shim implements just enough of the `--user` service surface to let that
# setup complete: it reads the unit from ~/.config/systemd/user/<name>.service
# and runs its ExecStart directly as a background process. There is no
# supervision/restart — a single start is enough for sandbox experimentation.
#
# Version-mismatch handling: if the unit's ExecStart hardcodes an interpreter
# path that does not exist (e.g. python3.13 on a python3.12 image) but the next
# token IS executable (the venv's `chroma` script, whose shebang points at the
# right interpreter), the interpreter token is dropped and the script is run
# directly. This makes the shipped unit work regardless of the venv's python
# minor version.
set -euo pipefail

RUNDIR="$HOME/.config/systemd-shim"
mkdir -p "$RUNDIR"

# Strip systemd-only flags; keep positional args (verb + unit).
NOW=0
pos=()
for a in "$@"; do
  case "$a" in
    --now) NOW=1 ;;
    --user|--system|--quiet|-q|--no-block|--no-pager|--no-ask-password) : ;;
    *) pos+=("$a") ;;
  esac
done

verb="${pos[0]:-}"
unit="${pos[1]:-}"

unit_file() {
  local u="$1"
  [[ "$u" == *.service ]] || u="$u.service"
  printf '%s/.config/systemd/user/%s\n' "$HOME" "$u"
}
pid_file() { printf '%s/%s.pid\n' "$RUNDIR" "${unit%.service}"; }
expand_h() { sed "s|%h|$HOME|g"; }

start_unit() {
  local f; f="$(unit_file "$unit")"
  [ -f "$f" ] || { echo "shim systemctl: unit not found: $f" >&2; exit 5; }

  local exec_line workdir logfile
  exec_line="$(grep -m1 -E '^ExecStart=' "$f" | sed 's/^ExecStart=//' | expand_h)"
  workdir="$(grep -m1 -E '^WorkingDirectory=' "$f" | sed 's/^WorkingDirectory=//' | expand_h || true)"
  logfile="$(grep -m1 -E '^StandardOutput=append:' "$f" | sed 's/^StandardOutput=append://' | expand_h || true)"

  [ -n "${workdir:-}" ] && { mkdir -p "$workdir"; cd "$workdir"; }
  if [ -n "${logfile:-}" ]; then mkdir -p "$(dirname "$logfile")"; else logfile=/dev/null; fi

  # shellcheck disable=SC2206
  local argv=($exec_line)
  if [ "${#argv[@]}" -ge 2 ] && [ ! -x "${argv[0]}" ] && [ -x "${argv[1]}" ]; then
    echo "shim systemctl: interpreter '${argv[0]}' absent — running '${argv[1]}' via its shebang"
    argv=("${argv[@]:1}")
  fi

  local pf; pf="$(pid_file)"
  if [ -f "$pf" ] && kill -0 "$(cat "$pf")" 2>/dev/null; then
    echo "shim systemctl: ${unit} already running (PID $(cat "$pf"))"
    return 0
  fi

  setsid "${argv[@]}" >>"$logfile" 2>&1 < /dev/null &
  echo $! > "$pf"
  echo "shim systemctl: started ${unit} (PID $(cat "$pf")) -> ${logfile}"
}

stop_unit() {
  local pf; pf="$(pid_file)"
  if [ -f "$pf" ]; then kill "$(cat "$pf")" 2>/dev/null || true; rm -f "$pf"; fi
  echo "shim systemctl: stopped ${unit}"
}

is_running() {
  local pf; pf="$(pid_file)"
  [ -f "$pf" ] && kill -0 "$(cat "$pf")" 2>/dev/null
}

case "$verb" in
  daemon-reload|daemon-reexec) exit 0 ;;
  enable|start|restart)        start_unit ;;
  disable|stop)                stop_unit ;;
  is-enabled)                  echo "enabled"; exit 0 ;;
  is-active)                   if is_running; then echo active; exit 0; else echo inactive; exit 3; fi ;;
  status)                      if is_running; then echo "${unit}: active (PID $(cat "$(pid_file)"))"; exit 0; else echo "${unit}: inactive"; exit 3; fi ;;
  *)                           exit 0 ;;
esac
