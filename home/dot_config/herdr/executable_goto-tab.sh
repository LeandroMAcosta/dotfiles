#!/usr/bin/env bash
# Focus tab N of the current herdr workspace, creating tabs up to N if it does
# not exist yet. herdr's own switch_tab is a no-op when the tab is missing;
# this makes alt+N behave like an i3 workspace switch, where $mod+3 always
# lands you on 3.
#
# Bound to alt+1..9 through [[keys.command]] entries in config.toml.
# Tabs are positional, so reaching tab 3 from a single tab creates 2 and 3.
set -euo pipefail

target="${1:-}"
if [[ ! "$target" =~ ^[1-9]$ ]]; then
  echo "usage: $(basename "$0") <1-9>" >&2
  exit 2
fi

# Custom commands run detached, so PATH may be minimal; resolve herdr up front.
HERDR="$(command -v herdr || true)"
[[ -x "$HERDR" ]] || HERDR="/opt/homebrew/bin/herdr"
[[ -x "$HERDR" ]] || { echo "herdr not found on PATH" >&2; exit 1; }

# The workspace holding the focused tab is the one the user is looking at.
workspace="$("$HERDR" tab list | jq -r '.result.tabs[] | select(.focused) | .workspace_id' | head -1)"
[[ -n "$workspace" ]] || { echo "no focused tab; is herdr running?" >&2; exit 1; }

tab_ids() {
  "$HERDR" tab list --workspace "$workspace" | jq -r '.result.tabs[].tab_id'
}

# Pad with empty tabs until position $target exists. Bounded by $target so a
# create that silently fails cannot spin.
for (( i = 0; i < target; i++ )); do
  (( $(tab_ids | wc -l) >= target )) && break
  "$HERDR" tab create --workspace "$workspace" --no-focus >/dev/null
done

tab_id="$(tab_ids | sed -n "${target}p")"
[[ -n "$tab_id" ]] || { echo "could not reach tab $target in $workspace" >&2; exit 1; }

"$HERDR" tab focus "$tab_id" >/dev/null
