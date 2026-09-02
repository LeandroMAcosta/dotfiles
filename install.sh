#!/usr/bin/env bash
set -euo pipefail

# Bootstrap only. Everything else — file deploys, per-OS templating, externals
# (OMZ, p10k, TPM), brew/pacman packages, macOS defaults — is chezmoi's job.
# Day to day: edit files in the repo and run `chezmoi apply`, or edit deployed
# files and pull changes back with `chezmoi re-add`.

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! command -v chezmoi &>/dev/null; then
  echo "==> Installing chezmoi..."
  if [[ "$(uname -s)" == "Darwin" ]] && command -v brew &>/dev/null; then
    brew install chezmoi
  elif command -v pacman &>/dev/null; then
    sudo pacman -S --needed --noconfirm chezmoi
  else
    sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
    export PATH="$HOME/.local/bin:$PATH"
  fi
fi

# Renders home/.chezmoi.toml.tmpl into ~/.config/chezmoi/chezmoi.toml (pinning
# this checkout as the source) and applies everything.
chezmoi init --source "$DOTFILES_DIR" --apply

echo ""
echo "Done! Run 'chezmoi diff' any time to see pending changes."

# 1Password manual setup hint (secrets + SSH keys need it)
if ! command -v op &>/dev/null || ! op account list &>/dev/null 2>&1; then
  echo ""
  echo "==> 1Password manual setup needed:"
  echo "  1. Open 1Password app → Settings → Developer"
  echo "     - Enable 'Integrate with 1Password CLI'"
  echo "     - Enable 'Use the SSH Agent'"
  echo "  2. Run: op plugin init aws"
  echo "  3. Run: load-secrets (to verify secrets injection)"
fi
