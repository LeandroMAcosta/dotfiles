#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Installing dotfiles from $DOTFILES_DIR"

# --- Homebrew ---
if ! command -v brew &>/dev/null; then
  echo "==> Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Apple Silicon
  if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
fi

echo "==> Installing Homebrew packages..."
if ! brew bundle --file="$DOTFILES_DIR/Brewfile" 2>&1; then
  echo "  (some packages failed to install, see errors above)"
fi

# --- Oh My Zsh ---
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  echo "==> Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# --- Powerlevel10k ---
P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
if [[ ! -d "$P10K_DIR" ]]; then
  echo "==> Installing Powerlevel10k..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
fi

# --- Zsh plugins ---
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
  echo "==> Installing zsh-autosuggestions..."
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
  echo "==> Installing zsh-syntax-highlighting..."
  git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

# --- TPM (tmux plugin manager) ---
TPM_DIR="$HOME/.tmux/plugins/tpm"
if [[ ! -d "$TPM_DIR" ]]; then
  echo "==> Installing TPM..."
  git clone --depth=1 https://github.com/tmux-plugins/tpm "$TPM_DIR"
fi

# --- Symlink dotfiles ---
link_file() {
  local src="$1" dst="$2"
  if [[ -e "$dst" && ! -L "$dst" ]]; then
    echo "  Backing up $dst -> ${dst}.bak"
    mv "$dst" "${dst}.bak"
  fi
  ln -sf "$src" "$dst"
  echo "  Linked $dst -> $src"
}

echo "==> Linking config files..."
link_file "$DOTFILES_DIR/.zshrc"   "$HOME/.zshrc"
link_file "$DOTFILES_DIR/.p10k.zsh" "$HOME/.p10k.zsh"

# Link everything in config/ to ~/.config/
if [[ -d "$DOTFILES_DIR/config" ]]; then
  for dir in "$DOTFILES_DIR/config"/*/; do
    dir_name="$(basename "$dir")"
    mkdir -p "$HOME/.config"
    link_file "$DOTFILES_DIR/config/$dir_name" "$HOME/.config/$dir_name"
    echo "  Linked ~/.config/$dir_name"
  done
fi

echo ""
echo "Done! Restart your terminal or run: source ~/.zshrc"
