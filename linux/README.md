# Linux (Arch) playbook

Written before the machine exists — validate everything on first boot. The repo
already renders Linux variants for everything portable; this file covers the
distro-specific parts chezmoi cannot decide alone.

## Bootstrap

```bash
git clone git@github.com:LeandroMAcosta/dotfiles.git ~/Workspace/personal/dotfiles
cd ~/Workspace/personal/dotfiles && ./install.sh
```

What applies automatically on Linux: zsh + OMZ + p10k (externals), tmux
(wl-copy clipboard, zsh panes), nvim, yazi, opencode, git, aws, claude,
`~/.secrets.env.tpl`, ssh config with the Linux 1Password socket
(`~/.1password/agent.sock`), and the **untested** pacman package script
(`home/.chezmoiscripts/run_onchange_after_linux-arch-packages.sh.tmpl` — review
it before the first apply). Skipped on Linux: herdr, ghostty config, all
darwin scripts.

## Option A: Omarchy (curated Hyprland, more friction)

Omarchy's model: defaults in `/usr/share/omarchy` (never edit), your copies in
`~/.config` — BUT `omarchy-refresh-*` utilities and update migrations rewrite
several `~/.config` files (tmux, ghostty, hyprland; timestamped backups are
made). Sources: omarchy.org/manual/dotfiles, the refresh system docs.

- **Login shell stays bash.** Do NOT `chsh` to zsh — SDDM session scripts and
  Hyprland startup assume bash and a wrong shell can black-screen the machine.
  Get zsh by setting the terminal's command instead, e.g. in ghostty:
  `command = /usr/bin/zsh`.
- **ghostty:** deliberately unmanaged by chezmoi here (`.chezmoiignore.tmpl`).
  Omarchy's config includes the active theme via
  `~/.config/omarchy/current/theme`; replacing the file breaks theme switching.
  Merge by hand: keep Omarchy's file, add personal lines (font size, padding,
  `command = /usr/bin/zsh`). Re-check after `omarchy-refresh-*` runs.
- **tmux:** Omarchy 3 ships its own `~/.config/tmux/tmux.conf` (prefix
  `Ctrl+Space`, no TPM). chezmoi overwrites it with ours on apply — that is
  intended — but `omarchy-refresh-tmux` can put theirs back. Sanctioned fix:
  drop a hook in `~/.config/omarchy/hooks/` that runs `chezmoi apply` after
  refresh/theme-set, so ours always wins.
- **Hyprland:** put personal keybinds/monitors in Omarchy's designated override
  files (`~/.config/hypr/bindings.conf`, `monitors.conf`, ...) — those are
  user-owned by contract and survive updates. Once real configs exist, add
  them to the repo as `home/dot_config/hypr/...` (and un-ignore on darwin is
  irrelevant — they simply do not deploy there if guarded).
- **nvim:** Omarchy ships LazyVim too; our config replaces it cleanly. The
  repo's `omarchy-theme.lua` plugin auto-imports
  `~/.config/omarchy/current/theme/neovim.lua` when present, so
  `omarchy-theme-set` keeps nvim in sync.
- **herdr:** not available; Hyprland workspaces + the i3-style `alt` chords
  cover its role natively.

## Option B: CachyOS (near-zero friction)

CachyOS customizes below `$HOME` (optimized kernel/repos, sysctl/udev in /etc);
home configs come from `/etc/skel` once at user creation and are never touched
again — plain pacman semantics, no refresh scripts. Its official zsh setup is
the same stack as ours (OMZ + p10k + autosuggestions + syntax-highlighting +
fzf), and picking zsh in the installer / `chsh` is supported. Our repo layers
on with no special handling: just run `./install.sh` and let chezmoi own
`~/.zshrc` and `~/.config/*`. Only trap: reinstalling over a preserved /home
can overwrite fish/alacritty configs (calamares issue #140).

## Both

- 1Password: install `1password` + `1password-cli` (AUR), enable CLI
  integration + SSH agent in the app; the ssh config already points at
  `~/.1password/agent.sock`.
- Notifications: Claude Code hooks use `notify-send` (libnotify) — installed by
  the package script.
- Fonts: `ttf-meslo-nerd` replaces the Homebrew Meslo cask (p10k + tmux icons).
