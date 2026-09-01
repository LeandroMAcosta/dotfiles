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

- `install.sh` uses `copy_file()` to copy (**not** symlink) files to their targets. The copy is one-way: repo → `$HOME`. Editing `~/.zshrc` or `~/.claude/settings.json` in place does **not** update the repo, and the next `./install.sh` overwrites it. After changing a deployed file, copy it back into the repo, or the change is lost.
- Root-level dotfiles (`.zshrc`, `.p10k.zsh`) copy to `$HOME`.
- Everything under `config/` copies to `~/.config/<dir_name>/`.
- To add a new app config: place it in `config/<app>/` and `install.sh` picks it up automatically.
- To add a new root-level dotfile: add a `copy_file` line in `install.sh`.

> **`copy_file` does `rm -rf` on a directory destination.** If an app keeps
> runtime state (sockets, sessions, caches, plugins) in the same directory as its
> config, a directory copy destroys it. Existing exceptions: **TPM** is cloned
> after the tmux copy, and **herdr** is skipped in the `config/*/` loop with only
> its `config.toml` copied as a single file — otherwise deploying wipes
> `herdr.sock` and kills the running server. Check for this before adding a new
> `config/<app>/`.

## Key config files

| File | Target | Notes |
|------|--------|-------|
| `.zshrc` | `~/.zshrc` | Oh My Zsh with Powerlevel10k, fzf and zoxide integration. Starts no multiplexer — the iTerm profile decides |
| `config/tmux/tmux.conf` | `~/.config/tmux/tmux.conf` | Prefix is `C-a`, uses TPM + tilish (i3-style) |
| `config/nvim/` | `~/.config/nvim/` | LazyVim starter. `lazyvim.json` (enabled extras) and `lazy-lock.json` (pinned plugin commits) are tracked, so a fresh machine gets the same plugin set. After `:Lazy update` or enabling an extra, copy both back into the repo or the next `./install.sh` reverts them |
| `config/herdr/config.toml` | `~/.config/herdr/config.toml` | Prefix `C-a`, i3-style `alt` chords. Copied as a single file, not as a directory — see the `rm -rf` warning above. `__HOME__` in it is replaced with `$HOME` at deploy time, because herdr does not expand `~` inside `keys.command` |
| `config/herdr/goto-tab.sh` | `~/.config/herdr/goto-tab.sh` | Backs the `alt+1..9` bindings: focuses tab N, creating tabs up to N when it does not exist. herdr's own `switch_tab` is a no-op for a missing tab, so `alt+1..9` is bound to this instead of `switch_tab` |
| `config/yazi/` | `~/.config/yazi/` | File manager. Catppuccin flavors are vendored under `flavors/` so `install.sh` restores them |
| `config/ghostty/config` | `~/.config/ghostty/config` | Alternative terminal, installed alongside iTerm. `macos-option-as-alt` is the equivalent of iTerm's Option=Esc+ and the herdr `alt` chords need it |
| `claude/` | `~/.claude/` | Global `CLAUDE.md`, `settings.json`, rules, contexts, `statusline.sh` |
| `Brewfile` | N/A | Declarative list of brew packages, casks |

## iTerm2 prerequisite

`macos.sh` automates the iTerm2 setup (restart iTerm to apply).

Applied to every profile:
- **Option Key Sends = Esc+** on left + right Option, required so dead-key layouts (Spanish/Latin etc.) don't swallow tmux `Alt+letter` bindings (e.g. `Alt+N` rename-window).
- **Font = MesloLGS Nerd Font Mono 13**, required by Powerlevel10k and the tmux Catppuccin status bar icons.

It also syncs one profile per terminal mode. The profile chooses the multiplexer via its custom command, which is why `.zshrc` starts none — that keeps tmux and herdr pane shells from re-exec'ing a multiplexer, and leaves embedded shells (VSCode, Cursor, Orca) plain:

| Profile | Command | Notes |
|---------|---------|-------|
| `Default` | *(none)* | Plain login shell. Stays iTerm's default profile |
| `tmux` | `tmux new-session -A -s main` | Attaches to the shared `main` session, creating it if absent |
| `herdr` | `herdr` | Launches the herdr terminal workspace manager |

Binaries are resolved with `command -v`, so it works on ARM and Intel Homebrew. The sync is idempotent: missing profiles are created from the default profile, existing ones have their command refreshed, and a profile whose binary is absent is skipped rather than created broken.

## Conventions

- `brew.sh` is a separate script from `install.sh` — Homebrew installation is intentionally decoupled from config deployment.
