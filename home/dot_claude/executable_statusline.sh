#!/usr/bin/env bash
# Claude Code statusline.
# Receives session JSON on stdin; whatever this prints is rendered. Setting a
# custom statusLine replaces the built-in one entirely, so anything not printed
# here is not shown — that is why plan usage has to be read explicitly below.
# Field reference: https://code.claude.com/docs/en/statusline

input=$(cat)

# Forward the payload to Orca's hook first so the IDE keeps receiving session
# data. That script writes nothing to stdout (it POSTs to a local endpoint), so
# chaining it here is safe and keeps the Orca integration intact.
orca="$HOME/.orca/agent-hooks/claude-statusline.sh"
if [ -x "$orca" ]; then
  printf '%s' "$input" | "$orca" >/dev/null 2>&1 || true
fi

j() { printf '%s' "$input" | jq -r "$1" 2>/dev/null; }

MODEL=$(j '.model.display_name // "?"')
EFFORT=$(j '.effort.level // ""')
FAST=$(j '.fast_mode // false')
DIR=$(j '.workspace.current_dir // .cwd // ""')
FIVE=$(j '.rate_limits.five_hour.used_percentage // empty')
FIVE_AT=$(j '.rate_limits.five_hour.resets_at // empty')
WEEK=$(j '.rate_limits.seven_day.used_percentage // empty')
PCT=$(j '.context_window.used_percentage // 0')
WIN=$(j '.context_window.context_window_size // 200000')

# Catppuccin Mocha, to match the tmux status bar and the herdr theme.
R=$'\033[0m'
BLUE=$'\033[38;2;137;180;250m'
PEACH=$'\033[38;2;250;179;135m'
GREEN=$'\033[38;2;166;227;161m'
RED=$'\033[38;2;243;139;168m'
DIM=$'\033[38;2;108;112;134m'

SEP="${DIM}❯${R}"

# Model, with a bolt for fast mode and a dot for the reasoning effort level.
seg_model="${BLUE}󰚩 ${MODEL}${R}"
[ "$FAST" = "true" ] && seg_model="${seg_model} ${PEACH}${R}"
[ -n "$EFFORT" ] && seg_model="${seg_model} ${DIM}·${R} ${BLUE}${EFFORT}${R}"

# Working directory, $HOME collapsed to ~.
TILDE='~'
seg_dir="${PEACH} ${DIR/#$HOME/$TILDE}${R}"

# Branch and uncommitted file count, read from git (not present in the JSON).
seg_git=""
if [ -n "$DIR" ] && git -C "$DIR" rev-parse --git-dir >/dev/null 2>&1; then
  branch=$(git -C "$DIR" branch --show-current 2>/dev/null)
  [ -z "$branch" ] && branch=$(git -C "$DIR" rev-parse --short HEAD 2>/dev/null)
  dirty=$(git -C "$DIR" status --porcelain 2>/dev/null | wc -l | tr -d ' ')
  seg_git="${PEACH} ${branch}${R}"
  [ "${dirty:-0}" -gt 0 ] && seg_git="${seg_git} ${GREEN}+${dirty}${R}"
fi

# Plan usage: the 5-hour session window and the rolling 7-day one. Both are
# absent until the first API response of a session, and each window disappears
# once it resets, so every part is optional.
usage_color() {
  if [ "$1" -ge 85 ]; then printf '%s' "$RED"
  elif [ "$1" -ge 60 ]; then printf '%s' "$PEACH"
  else printf '%s' "$GREEN"
  fi
}

# Context used as a percentage of the window, with the window size abbreviated.
# This is the one that warns before auto-compact, so it shares the usage colors.
if [ "$WIN" -ge 1000000 ]; then
  winf="$((WIN / 1000000))M"
else
  winf="$((WIN / 1000))K"
fi
ctx=${PCT%.*}
seg_ctx="$(usage_color "$ctx")▤ ${ctx}%/${winf}${R}"

seg_usage=""
if [ -n "$FIVE" ]; then
  n=${FIVE%.*}
  seg_usage="$(usage_color "$n")5h ${n}%${R}"
  # The reset time only matters when the window is filling up.
  if [ "$n" -ge 50 ] && [ -n "$FIVE_AT" ]; then
    at=$(date -r "$FIVE_AT" +%H:%M 2>/dev/null || date -d "@$FIVE_AT" +%H:%M 2>/dev/null)
    [ -n "$at" ] && seg_usage="${seg_usage} ${DIM}till ${at}${R}"
  fi
fi
if [ -n "$WEEK" ]; then
  n=${WEEK%.*}
  [ -n "$seg_usage" ] && seg_usage="${seg_usage} ${DIM}·${R} "
  seg_usage="${seg_usage}$(usage_color "$n")7d ${n}%${R}"
fi

line="${seg_model} ${SEP} ${seg_dir}"
[ -n "$seg_git" ] && line="${line} ${SEP} ${seg_git}"
line="${line} ${SEP} ${seg_ctx}"
[ -n "$seg_usage" ] && line="${line} ${SEP} ${seg_usage}"

printf '%s\n' "$line"
