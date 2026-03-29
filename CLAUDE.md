# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

macOS dotfiles repo for a development environment. Configs are **copied** (not symlinked) to their destinations by `install.sh`.

## Commands

```bash
# Full setup (Oh My Zsh, Powerlevel10k, zsh plugins, TPM, copy configs)
./install.sh

# Install Homebrew and all packages/casks from Brewfile
./brew.sh

# Regenerate Brewfile from currently installed packages
brew bundle dump --file=~/dotfiles/Brewfile --force
```

## How configs are deployed

- `install.sh` uses `copy_file()` to copy (not symlink) files to their targets. Since configs are symlinked at the filesystem level by the user's workflow, edits in `~/.config/` or `~/.zshrc` are reflected here automatically.
- Root-level dotfiles (`.zshrc`, `.p10k.zsh`) copy to `$HOME`.
- Everything under `config/` copies to `~/.config/<dir_name>/`.
- To add a new app config: place it in `config/<app>/` and `install.sh` picks it up automatically.
- To add a new root-level dotfile: add a `copy_file` line in `install.sh`.

## Key config files

| File | Target | Notes |
|------|--------|-------|
| `.zshrc` | `~/.zshrc` | Auto-starts tmux, Oh My Zsh with Powerlevel10k, fzf and zoxide integration |
| `config/tmux/tmux.conf` | `~/.config/tmux/tmux.conf` | Prefix is `C-a`, uses TPM + tilish (i3-style) |
| `config/nvim/` | `~/.config/nvim/` | LazyVim starter (lazy.nvim bootstrap) |
| `Brewfile` | N/A | Declarative list of brew packages, casks |

## iTerm2 prerequisite

**Left Option Key must be set to Esc+** (Settings → Profiles → Keys → General) for all `Alt+` tmux keybindings to work.

## Conventions

- `brew.sh` is a separate script from `install.sh` — Homebrew installation is intentionally decoupled from config deployment.
