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

## Regenerating the Brewfile

```bash
brew bundle dump --file=~/dotfiles/Brewfile --force
```
