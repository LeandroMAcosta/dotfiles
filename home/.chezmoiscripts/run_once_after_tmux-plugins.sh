#!/usr/bin/env bash
set -euo pipefail

# Install TPM-managed plugins once. TPM itself is a chezmoi external at the XDG
# path; plugin updates stay TPM's job (prefix+U) after this first install.
command -v tmux &>/dev/null || exit 0

TPM_PLUGIN_DIR="$HOME/.config/tmux/plugins"
[[ -x "$TPM_PLUGIN_DIR/tpm/bin/install_plugins" ]] || exit 0

for plugin_name in tmux-tilish tmux tmux-resurrect tmux-continuum; do
  if [[ ! -d "$TPM_PLUGIN_DIR/$plugin_name" ]]; then
    echo "==> Installing tmux plugins..."
    # If a tmux server is already running (e.g. apply invoked from inside
    # tmux), reload the conf there so TPM sets TMUX_PLUGIN_MANAGER_PATH.
    # Otherwise spin up a throwaway detached server.
    if tmux list-sessions &>/dev/null; then
      tmux source-file "$HOME/.config/tmux/tmux.conf"
      "$TPM_PLUGIN_DIR/tpm/bin/install_plugins"
    else
      tmux -f "$HOME/.config/tmux/tmux.conf" new-session -d -s _tpm_install
      "$TPM_PLUGIN_DIR/tpm/bin/install_plugins"
      tmux kill-session -t _tpm_install 2>/dev/null || true
    fi
    break
  fi
done
