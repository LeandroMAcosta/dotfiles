#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- Ensure native ARM Homebrew on Apple Silicon ---
if [[ "$(uname -m)" == "arm64" || "$(sysctl -n hw.optional.arm64 2>/dev/null)" == "1" ]]; then
  BREW="/opt/homebrew/bin/brew"
  if [[ ! -f "$BREW" ]]; then
    echo "==> Installing Homebrew (ARM native)..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  eval "$($BREW shellenv)"
else
  # Intel Mac
  if ! command -v brew &>/dev/null; then
    echo "==> Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
fi

echo "==> Installing Homebrew packages..."
if ! brew bundle --file="$DOTFILES_DIR/Brewfile" 2>&1; then
  echo "  (some packages failed to install, see errors above)"
fi

echo "Done! Homebrew packages installed."
