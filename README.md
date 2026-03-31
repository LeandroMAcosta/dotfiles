# dotfiles

My macOS development environment configuration.

## What's included

| Path | Description |
|------|-------------|
| `.zshrc` | Zsh config (Oh My Zsh + Powerlevel10k) |
| `.p10k.zsh` | Powerlevel10k theme config |
| `Brewfile` | Homebrew packages, casks, and VS Code extensions |
| `config/` | App configs (symlinked to `~/.config/`) |
| `install.sh` | One-command setup script |

## Quick start

```bash
git clone git@github.com:LeandroMAcosta/dotfiles.git ~/dotfiles
cd ~/dotfiles
chmod +x install.sh
./install.sh
```

## Adding new configs

For apps that use `~/.config/` (nvim, alacritty, etc.):

```bash
# Example: add neovim config
cp -r ~/.config/nvim ~/dotfiles/config/nvim
```

The install script automatically symlinks everything in `config/` to `~/.config/`.

For standalone dotfiles (e.g. `.gitconfig`, `.tmux.conf`), copy them to the repo root and add a `link_file` line in `install.sh`.

## Updating

After changing configs on your machine, sync back:

```bash
cd ~/dotfiles
# Configs are symlinked, so changes are already here
git add -A && git commit -m "update configs"
git push
```

## Keybindings

### Terminal (zsh)

| Shortcut | Action |
|----------|--------|
| `Ctrl+C` | Cancel running command |
| `Ctrl+A` | Go to beginning of line |
| `Ctrl+E` | Go to end of line |
| `Ctrl+U` | Delete entire line |
| `Ctrl+W` | Delete previous word |
| `Ctrl+R` | Search command history |
| `Ctrl+L` | Clear screen |
| `Ctrl+D` | Close terminal (EOF) |

### Tmux (prefix: `Ctrl+Space`)

| Shortcut | Action |
|----------|--------|
| `Ctrl+Space, \|` | Split vertical (side by side) |
| `Ctrl+Space, -` | Split horizontal (top/bottom) |
| `Ctrl+Space, r` | Reload config |
| `Alt+←/→/↑/↓` | Move between panes |
| `Alt+Shift+←/→/↑/↓` | Swap panes |
| `Alt+Enter` | New vertical split in current path |
| `Alt+Shift+Q` | Close pane |
| `Shift+←/→` | Switch windows |
| `Ctrl+Space, [` | Enter copy mode (vi keys) |
| `v` (copy mode) | Start selection |
| `y` (copy mode) | Copy to clipboard |

## iTerm2 setup

Go to **Settings → Profiles → Keys → General** and set **Left Option Key** to **Esc+**. This makes Option send escape sequences that tmux recognizes as Meta/Alt (by default macOS uses Option for special characters like `@`, `#`, `~`). Required for all `Alt+` keybindings in the tmux config.

## Regenerating the Brewfile

```bash
brew bundle dump --file=~/dotfiles/Brewfile --force
```
