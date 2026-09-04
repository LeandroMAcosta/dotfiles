# AGENTS.md

This file provides guidance to coding agents working with this repository.

## Overview

Cross-platform dotfiles repo (macOS today, Arch Linux prepared), managed with **chezmoi**. The chezmoi source lives under `home/` (selected by `.chezmoiroot`); `~/.config/chezmoi/chezmoi.toml` pins this checkout as the source, so `chezmoi apply` deploys straight from the repo — no second clone.

## Commands

```bash
# First-time setup on a new machine (installs chezmoi, then init --apply)
./install.sh

# Day to day
chezmoi diff            # what would change
chezmoi apply           # deploy repo -> $HOME (also runs scripts, refreshes externals)
chezmoi re-add          # pull edits made in $HOME back into the repo
chezmoi status          # drift summary

# Regenerate Brewfile from currently installed packages
brew bundle dump --file=~/Workspace/personal/dotfiles/Brewfile --force
```

## How deployment works

- chezmoi **copies** (renders) files into `$HOME` on `chezmoi apply`; nothing is symlinked. It applies file-by-file, so unmanaged runtime state (herdr's `herdr.sock`, tmux plugin clones, nvim caches) is never wiped — the old `rm -rf` hazard is gone.
- Filename attributes encode target + metadata: `dot_zshrc.tmpl` → `~/.zshrc` (templated), `private_` → mode 600, `executable_` → mode 755.
- `.tmpl` files are Go templates. OS branching uses `{{ if eq .chezmoi.os "darwin" }}` / `"linux"`; `{{ .chezmoi.homeDir }}` replaces the old `__HOME__` sed hack (herdr needs absolute paths in `keys.command`).
- `home/.chezmoiignore.tmpl` skips files per OS (herdr and ghostty are not managed on Linux — see `linux/README.md`).
- `home/.chezmoiexternal.toml` installs Oh My Zsh, Powerlevel10k, zsh plugins and TPM as weekly-refreshed tarballs; OMZ's own updater is disabled in `.zshrc` because of this.
- `home/.chezmoiscripts/` replaces the old install.sh/brew.sh/macos.sh logic: `run_onchange_before_darwin-brew-packages` (brew bundle, re-runs when Brewfile changes), `run_onchange_after_darwin-macos-defaults` (former macos.sh: defaults + iTerm profile sync), `run_once_after_ssh-keys` (GitHub/Bitbucket keys from 1Password), `run_onchange_after_claude-skills`, `run_once_after_tmux-plugins`, `run_onchange_after_darwin-herdr-integrations`, and an **untested** `run_onchange_after_linux-arch-packages` stub.
- Scripts whose whole body sits inside an OS guard render empty on the other OS, and chezmoi skips empty scripts.

## Editing rules

- Edit files in the repo (`home/...`) and run `chezmoi apply`. If you edited the deployed file in `$HOME` instead, run `chezmoi re-add` to capture it — for `.tmpl` targets re-add rewrites the template with rendered values, so prefer editing the template for those and check `chezmoi diff` afterwards.
- `~/.claude/plugins/known_marketplaces.json` is deliberately **unmanaged** (machine paths + timestamps churn).
- `config/nvim` equivalent lives at `home/dot_config/nvim/`. After `:Lazy update`, `chezmoi re-add ~/.config/nvim/lazy-lock.json` (and `lazyvim.json` if extras changed) or the next apply reverts them.
- Secrets: `~/.secrets.env.tpl` (op:// references) is deployed as a plain file; `.zshrc` renders it via `op inject` into a 24h cache. Deliberately NOT chezmoi 1Password templating — that would hit 1Password on every `chezmoi diff`.

## Key targets

| Source | Target | Notes |
|------|--------|-------|
| `home/dot_zshrc.tmpl` | `~/.zshrc` | OMZ + p10k. Darwin-only: brew shellenv, `tm`/`hd` Ghostty aliases, libpq PATH, launchctl Orca block. Starts no multiplexer — the terminal profile decides |
| `home/dot_config/tmux/tmux.conf.tmpl` | `~/.config/tmux/tmux.conf` | Prefix `C-a`, TPM + tilish. Clipboard: pbcopy/wl-copy per OS |
| `home/dot_config/nvim/` | `~/.config/nvim/` | LazyVim. `omarchy-theme.lua` no-ops unless Omarchy's theme file exists |
| `home/dot_config/herdr/` | `~/.config/herdr/` | Darwin only. Only config.toml + goto-tab.sh managed; runtime socket untouched |
| `home/dot_config/ghostty/config.tmpl` | `~/.config/ghostty/config` | Darwin only via ignore on Linux (Omarchy owns it there) |
| `home/dot_hammerspoon/init.lua` | `~/.hammerspoon/init.lua` | Darwin only. Display-focus hotkeys (`cmd+ctrl` family, clear of herdr's `ctrl+shift`/`alt`). Warps mouse with focus so ctrl+arrows Space-switching targets the focused display. No window-model WM here on purpose — they desync with native macOS Spaces |
| `home/private_dot_ssh/private_config.tmpl` | `~/.ssh/config` | 1Password agent socket per OS; colima Include darwin-only. chezmoi owns the whole file now (old awk-merge is gone) — local-only hosts belong in the template |
| `home/dot_claude/` | `~/.claude/` | settings.json templated: osascript vs notify-send hooks, homeDir path |
| `Brewfile` | N/A | Hashed into the darwin brew script; editing it triggers `brew bundle` on next apply |
| `linux/README.md` | N/A | Omarchy/CachyOS playbook for the future Arch machine |

## iTerm2 prerequisite

The darwin defaults script (`home/.chezmoiscripts/run_onchange_after_darwin-macos-defaults.sh.tmpl`) applies macOS defaults and the iTerm2 setup (restart iTerm to apply): Option=Esc+ on both keys (dead-key layouts would swallow `Alt+letter` otherwise), MesloLGS Nerd Font Mono 13, and one profile per terminal mode (`Default` plain, `tmux` attaches `main`, `herdr` launches herdr) — which is why `.zshrc` starts no multiplexer.

## Conventions

- Never edit `/usr/share`-style vendor trees or chezmoi's cache; the repo is the single source.
- `install.sh` is bootstrap-only; adding deploy logic there is wrong — use chezmoi attributes or a `.chezmoiscripts` script.
