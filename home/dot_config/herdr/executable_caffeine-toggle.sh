#!/usr/bin/env bash
# Keep the Mac awake for as long as an agent run needs, toggled from inside
# herdr. macOS has no persistent "stay awake" flag: caffeinate holds the power
# assertion only while its own process lives, so the toggle is really "is our
# caffeinate still running", tracked through a pid file.
#
# -i blocks idle system sleep and -s blocks sleep while on AC power. -d is
# deliberately left out: pinning the display on drains the battery and buys
# nothing for a background agent run.
#
# Bound to ctrl+shift+k through a [[keys.command]] entry in config.toml, and
# queried by the tab_bar_right status entry via the `status` argument.
set -euo pipefail

pidfile="${TMPDIR:-/tmp}/herdr-caffeinate.pid"
lockdir="${TMPDIR:-/tmp}/herdr-caffeinate.lock"

# Key repeats fire the binding detached and concurrently. Without a lock, two
# presses close enough together both read "not running", both spawn a
# caffeinate, and the second pid overwrites the first: the orphan keeps the
# assertion with nothing tracking it, so a later toggle-off leaves the Mac
# permanently awake while the indicator reads clear. mkdir is atomic, so
# whichever press creates the directory wins and the rest drop out — dropping a
# duplicate press is correct, it is the same keystroke arriving twice.
take_lock() {
  # A script killed between mkdir and the trap would wedge the toggle forever,
  # so an obviously abandoned lock is cleared rather than honoured.
  if [[ -d "$lockdir" ]] && [[ -z "$(find "$lockdir" -maxdepth 0 -mmin -1 2>/dev/null)" ]]; then
    rmdir "$lockdir" 2>/dev/null || true
  fi
  mkdir "$lockdir" 2>/dev/null || return 1
  trap 'rmdir "$lockdir" 2>/dev/null || true' EXIT
}

# A pid file outlives the process it names, and macOS reuses pids, so treat the
# file as a claim to verify rather than as the truth.
running_pid() {
  local pid
  [[ -f "$pidfile" ]] || return 1
  pid="$(cat "$pidfile" 2>/dev/null || true)"
  [[ "$pid" =~ ^[0-9]+$ ]] || return 1
  [[ "$(ps -p "$pid" -o comm= 2>/dev/null || true)" == *caffeinate ]] || return 1
  printf '%s\n' "$pid"
}

case "${1:-toggle}" in
status)
  # Both states are named. Printing nothing when off would let herdr clear the
  # slot, which reads the same as the entry being broken or the script missing.
  running_pid >/dev/null && printf 'AWAKE' || printf 'NOT AWAKE'
  ;;
toggle)
  # A press that loses the race is a duplicate, not a missed toggle.
  take_lock || exit 0
  if pid="$(running_pid)"; then
    kill "$pid" 2>/dev/null || true
    rm -f "$pidfile"
  else
    # Custom commands run detached and this script exits immediately, so
    # caffeinate is reparented and keeps holding the assertion.
    caffeinate -is >/dev/null 2>&1 &
    printf '%s\n' "$!" >"$pidfile"
  fi
  ;;
*)
  echo "usage: $(basename "$0") [toggle|status]" >&2
  exit 2
  ;;
esac
