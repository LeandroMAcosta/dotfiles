# AGENTS.md

This file provides guidance to coding agents working with this repository.

## Overview

Cross-platform dotfiles repo (macOS today, Arch Linux prepared), managed with **chezmoi**. Source state lives under `home/` (selected by `.chezmoiroot`); `chezmoi apply` renders it into `$HOME` directly from this checkout.

## Commands

```bash
./install.sh        # first-time bootstrap (installs chezmoi, init --apply)
chezmoi diff        # preview changes
chezmoi apply       # deploy repo -> $HOME
chezmoi re-add      # capture edits made in $HOME back into the repo
```

## Rules

- chezmoi copies (no symlinks) and applies file-by-file; unmanaged runtime state (herdr socket, TPM plugin clones) survives applies.
- Filename attributes: `dot_` → leading dot, `private_` → 0600, `executable_` → 0755, `.tmpl` → Go template. OS branches use `{{ if eq .chezmoi.os "darwin" }}`.
- Per-OS skips live in `home/.chezmoiignore.tmpl` (herdr + ghostty unmanaged on Linux). Externals (OMZ, p10k, zsh plugins, TPM) in `home/.chezmoiexternal.toml`. Former install.sh/brew.sh/macos.sh logic lives in `home/.chezmoiscripts/`.
- Edit repo sources, not deployed files; if a deployed file was edited, `chezmoi re-add` it (for `.tmpl` targets prefer editing the template and verify with `chezmoi diff`).
- `install.sh` is bootstrap-only — never add deploy logic there.
- See CLAUDE.md for the full key-target table and linux/README.md for the Arch/Omarchy plan.
