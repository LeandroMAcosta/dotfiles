#!/usr/bin/env bash
# Claude Code statusline.
# Receives session JSON on stdin; whatever this prints is rendered.
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
PCT=$(j '.context_window.used_percentage // 0')
WIN=$(j '.context_window.context_window_size // 200000')
COST=$(j '.cost.total_cost_usd // 0')
NAME=$(j '.session_name // ""')

# Catppuccin Mocha, to match the tmux status bar and the herdr theme.
R=$'\033[0m'
PINK=$'\033[38;2;245;194;231m'
BLUE=$'\033[38;2;137;180;250m'
PEACH=$'\033[38;2;250;179;135m'
GREEN=$'\033[38;2;166;227;161m'
TEXT=$'\033[38;2;205;214;244m'
DIM=$'\033[38;2;108;112;134m'
MAUVE=$'\033[38;2;203;166;247m'

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

# Context used as a percentage of the window, with the window size abbreviated.
if [ "$WIN" -ge 1000000 ]; then
  winf="$((WIN / 1000000))M"
else
  winf="$((WIN / 1000))K"
fi
pctf=$(printf '%.1f' "$PCT" 2>/dev/null || echo "$PCT")
seg_ctx="${TEXT}▤ ${pctf}%/${winf}${R}"

seg_cost="${GREEN}\$$(printf '%.2f' "$COST" 2>/dev/null || echo "$COST")${R}"

line="${MAUVE}π${R} ${SEP} ${seg_model} ${SEP} ${seg_dir}"
[ -n "$seg_git" ] && line="${line} ${SEP} ${seg_git}"
line="${line} ${SEP} ${seg_ctx} ${SEP} ${seg_cost}"

# Right-align the session name, padding with a rule. Width detection fails when
# there is no tty, so fall back to a fixed pad rather than a broken layout.
if [ -n "$NAME" ] && [ "$NAME" != "null" ]; then
  cols=${COLUMNS:-$(tput cols 2>/dev/null || echo 0)}
  plain=$(printf '%s' "$line" | sed $'s/\033\\[[0-9;]*m//g')
  used=$(( ${#plain} + ${#NAME} + 4 ))
  if [ "$cols" -gt "$used" ]; then
    pad=$(printf '%*s' "$((cols - used))" '' | tr ' ' '-')
  else
    pad="---"
  fi
  line="${line}  ${DIM}${pad}${R}  ${PEACH}${NAME}${R}"
fi

printf '%s\n' "$line"
