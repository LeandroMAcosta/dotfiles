#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Installing dotfiles from $DOTFILES_DIR"

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

# --- Copy dotfiles ---
copy_file() {
  local src="$1" dst="$2"
  # Remove old symlinks before copying
  if [[ -L "$dst" ]]; then
    rm "$dst"
  fi
  if [[ -d "$src" ]]; then
    rm -rf "$dst"
    cp -R "$src" "$dst"
  else
    cp -f "$src" "$dst"
  fi
  echo "  Copied $src -> $dst"
}

echo "==> Copying config files..."
copy_file "$DOTFILES_DIR/.zshrc"   "$HOME/.zshrc"
copy_file "$DOTFILES_DIR/.p10k.zsh" "$HOME/.p10k.zsh"
copy_file "$DOTFILES_DIR/.secrets.env.tpl" "$HOME/.secrets.env.tpl"

# SSH config (merge: dotfiles entries first, then append local-only hosts)
mkdir -p "$HOME/.ssh"
if [[ -f "$HOME/.ssh/config" ]]; then
  # Keep only Host blocks from existing config that are NOT in dotfiles
  dotfiles_hosts=$(awk '/^Host / { printf "%s,", $2 }' "$DOTFILES_DIR/ssh/config")
  local_entries=$(awk -v known="$dotfiles_hosts" '
    BEGIN { n=split(known, arr, ","); for (i=1;i<=n;i++) if (arr[i]!="") skip_host[arr[i]]=1 }
    /^Host / { skip = ($2 in skip_host) }
    !skip
  ' "$HOME/.ssh/config")
  cp -f "$DOTFILES_DIR/ssh/config" "$HOME/.ssh/config"
  if [[ -n "$local_entries" ]]; then
    printf '\n%s\n' "$local_entries" >> "$HOME/.ssh/config"
  fi
else
  cp -f "$DOTFILES_DIR/ssh/config" "$HOME/.ssh/config"
fi
chmod 600 "$HOME/.ssh/config"
echo "  Merged SSH config"

# AWS config (profiles/regions only, no credentials)
mkdir -p "$HOME/.aws"
copy_file "$DOTFILES_DIR/aws/config" "$HOME/.aws/config"

# Copy everything in config/ to ~/.config/
if [[ -d "$DOTFILES_DIR/config" ]]; then
  for dir in "$DOTFILES_DIR/config"/*/; do
    dir_name="$(basename "$dir")"
    mkdir -p "$HOME/.config"
    copy_file "$DOTFILES_DIR/config/$dir_name" "$HOME/.config/$dir_name"
  done
fi

# --- Install tmux plugins (only if missing) ---
plugin_missing=false
for plugin_name in tmux-tilish tmux tmux-resurrect tmux-continuum; do
  if [[ ! -d "$HOME/.tmux/plugins/$plugin_name" ]]; then
    plugin_missing=true
    break
  fi
done

if $plugin_missing; then
  echo "==> Installing tmux plugins..."
  tmux -f "$HOME/.config/tmux/tmux.conf" new-session -d -s _tpm_install 2>/dev/null || true
  "$HOME/.tmux/plugins/tpm/bin/install_plugins" || true
  tmux kill-session -t _tpm_install 2>/dev/null || true
else
  echo "==> Tmux plugins already installed, skipping"
fi

# --- Verify architecture ---
echo "==> Architecture check:"
echo "  uname -m: $(uname -m)"
echo "  arch:     $(arch)"
if [[ "$(uname -m)" == "arm64" ]]; then
  echo "  ✓ Running natively on Apple Silicon"
elif [[ "$(uname -m)" == "x86_64" && -d /opt/homebrew ]]; then
  echo "  ⚠ Running under Rosetta on Apple Silicon — check your terminal settings"
fi

# --- Claude Code config ---
if [[ -d "$DOTFILES_DIR/claude" ]]; then
  echo "==> Copying Claude Code configs..."
  mkdir -p "$HOME/.claude"
  copy_file "$DOTFILES_DIR/claude/CLAUDE.md"      "$HOME/.claude/CLAUDE.md"
  copy_file "$DOTFILES_DIR/claude/settings.json"   "$HOME/.claude/settings.json"

  if [[ -d "$DOTFILES_DIR/claude/rules" ]]; then
    mkdir -p "$HOME/.claude/rules"
    for rule in "$DOTFILES_DIR/claude/rules"/*.md; do
      copy_file "$rule" "$HOME/.claude/rules/$(basename "$rule")"
    done
  fi

  if [[ -d "$DOTFILES_DIR/claude/contexts" ]]; then
    mkdir -p "$HOME/.claude/contexts"
    for ctx in "$DOTFILES_DIR/claude/contexts"/*.md; do
      copy_file "$ctx" "$HOME/.claude/contexts/$(basename "$ctx")"
    done
  fi

  if [[ -f "$DOTFILES_DIR/claude/plugins/known_marketplaces.json" ]]; then
    mkdir -p "$HOME/.claude/plugins"
    copy_file "$DOTFILES_DIR/claude/plugins/known_marketplaces.json" "$HOME/.claude/plugins/known_marketplaces.json"
  fi
fi

# --- Claude Code skills ---
if command -v npx &>/dev/null; then
  echo "==> Installing Claude Code skills..."
  npx -y skills add JuliusBrussee/caveman -g -y --agent claude-code 2>/dev/null || true
  npx -y skills add nextlevelbuilder/ui-ux-pro-max-skill -g -y --agent claude-code 2>/dev/null || true
  npx -y skills add shadcn/ui -g -y --agent claude-code 2>/dev/null || true
fi

# --- Reload configs ---
source "$HOME/.zshrc" 2>/dev/null || true
tmux source-file "$HOME/.config/tmux/tmux.conf" 2>/dev/null || true

# --- 1Password setup check ---
if ! command -v op &>/dev/null || ! op account list &>/dev/null 2>&1; then
  echo ""
  echo "==> 1Password manual setup needed:"
  echo "  1. Open 1Password app → Settings → Developer"
  echo "     - Enable 'Integrate with 1Password CLI'"
  echo "     - Enable 'Use the SSH Agent'"
  echo "  2. Run: op plugin init aws"
  echo "  3. Run: load-secrets (to verify secrets injection)"
fi

echo ""
echo "Done! Configs installed and reloaded."
