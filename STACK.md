# STACK.md

The tools behind the dev workflow, by layer, and how they fit together. Config
locations refer to this repo's chezmoi source (`home/`); see AGENTS.md for how
deployment works.

## Terminal & multiplexing

| Tool | Role | Config |
|---|---|---|
| **Ghostty** | Primary terminal. `tm` alias opens it attached to tmux `main`; `hd` opens it running herdr | `home/dot_config/ghostty/` |
| **iTerm2** | Secondary. The darwin defaults script builds 3 profiles: `Default` (plain shell), `tmux` (attaches `main`), `herdr` (launches herdr) — the shell itself starts no multiplexer | profiles via `run_onchange_after_darwin-macos-defaults` |
| **herdr** | Terminal workspace manager for AI agents. Prefix `ctrl+a`; direct `ctrl+shift` chords: `n` new tab, `enter`/`minus` splits, `w` close pane, `r` resize, arrows for tabs (←→) and spaces (↑↓); i3-style `alt+*` chords; `alt+1..9` goto-or-create tab | `home/dot_config/herdr/` |
| **tmux** | Classic sessions. Prefix `C-a`, TPM + tilish, Catppuccin theme, per-OS clipboard | `home/dot_config/tmux/` |

## Shell

- **zsh** + **Oh My Zsh** + **Powerlevel10k** — OMZ/p10k/plugins installed as
  weekly-refreshed chezmoi externals (OMZ's own updater disabled).
- **MesloLGS Nerd Font** — required by p10k and the tmux status bar icons.
- CLI kit: **fzf** (fuzzy find), **zoxide** (cd), **yazi** (file manager TUI),
  **mprocs** (parallel process runner), **jq**, **wget**.

## Editor

- **Neovim + LazyVim** (`home/dot_config/nvim/`). Custom watcher in
  `autocmds.lua`: externally edited files (e.g. by a Claude session) reload
  live, and files not yet open auto-open in the current window, capped at 3
  per burst so a git checkout doesn't flood buffers.
- **Cursor** — GUI editor.

## AI & agents

- **Claude Code** — CLI + desktop app. Settings templated by chezmoi
  (`home/dot_claude/`): notification hooks (osascript on macOS, notify-send on
  Linux), skills synced by `run_onchange_after_claude-skills`.
- **opencode** — alternative agent TUI (`home/dot_config/opencode/`).
- **Orca** — worktree/agent orchestration app; its hook is wired into Claude's
  settings.json.
- **Obsidian** — notes vault, connected over MCP.

## Git & repo management

- **git**, **gh** (also the git credential helper via `gh auth setup-git`),
  **lazygit**.
- **chezmoi** — the glue. `home/` is the source of truth; `.chezmoiscripts/`
  runs brew bundle, macOS defaults + iTerm profiles, SSH keys from 1Password,
  tmux plugins, herdr integrations, and Claude skills on apply.

## macOS windows & input

- **Hammerspoon** (`home/dot_hammerspoon/init.lua`) — display focus.
  `cmd+ctrl+arrows`/`hjkl` focus displays (logical row: built-in | LG | bottom
  panel); `cmd+ctrl+shift+arrows` throw the focused window. The pointer warps
  with focus on purpose: macOS applies `ctrl+left/right` Space-switching to
  the display under the mouse. No window-model WM here on purpose — they
  desync with native macOS Spaces.
- **Logi Options+** — Logitech mouse/keyboard.
- Modifier map, to keep families from colliding: herdr owns `ctrl+shift` and
  `alt`, Hammerspoon owns `cmd+ctrl`, the terminals keep plain `cmd`.

## Secrets & network

- **1Password + op CLI** — SSH agent (`home/private_dot_ssh/`), and
  `~/.secrets.env.tpl` rendered by `op inject` into a 24h cache from `.zshrc`
  (deliberately not chezmoi's 1Password templating, which would hit 1Password
  on every `chezmoi diff`). Secrets live in the "Developer Secrets" vault.
- **Tailscale** — mesh VPN; the path for a future `herdr --remote` to an
  always-on machine.
- **colima** + **docker-compose** — container runtime (ssh config Include).
- **awscli** — profile `esqueldev`.

## Runtimes & data

- **node**, **python 3.12**, **DBeaver** (DB GUI), libpq on PATH.

## Prepared, dormant

- `linux/README.md` — Omarchy/CachyOS playbook for a future Arch machine.
  `.chezmoiignore.tmpl` already skips the darwin-only pieces there (herdr,
  ghostty, hammerspoon); an untested arch-packages script stub exists.
