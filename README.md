# dotfiles

My macOS development environment configuration.

## What's included

| Path | Description |
|------|-------------|
| `.zshrc` | Zsh config (Oh My Zsh + Powerlevel10k) |
| `.p10k.zsh` | Powerlevel10k theme config |
| `Brewfile` | Homebrew packages, casks, and VS Code extensions |
| `config/` | App configs (symlinked to `~/.config/`) |
| `ssh/config` | SSH hosts (local-only hosts preserved on install) |
| `git/` | `~/.gitconfig` + gitdir-scoped `includeIf` files |
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

## Workspace structure

All code lives under `~/Workspace/`, organized by purpose:

```
~/Workspace/
├── work/        # Client / employer projects, grouped by org
│   ├── engbim/      # own workspace: repos/, docs/, notes/, unity/, ...
│   ├── esqueldev/   # repo with platform/, products/, templates/
│   ├── goply/       # goply-iac, yendo-backend, yendo-frontend
│   ├── improving/   # orion-backend, MediaPro, nambdo, earnup, trinet, ...
│   ├── taller/      # own workspace: Repos/, Reports/, docs/, ...
│   └── techwarely/  # admin/, repos/
├── personal/    # Personal projects (incl. this dotfiles repo)
│   └── side-projects/   # smaller experiments
├── thesis/      # Academic work
└── archive/     # Inactive / legacy projects (yendo, canalytics, ...)
```

Convention: top level is by purpose (`work` / `personal` / `thesis` / `archive`),
second level groups by org or category. Most leaves are individual repos with
their own git remote (nothing here is a monorepo); a few orgs (`engbim`, `taller`)
are themselves workspace folders that nest their repos under a `repos/` subdir.

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

## MediaPro (Azure DevOps) SSH setup

The `ssh/config` defines `Host ssh.dev.azure.com-mediapro` with `IdentityFile ~/.ssh/mediapro_azure.pub`. The private key lives in 1Password (item **Azure DevOps - MediaPro**, vault *Developer Secrets*) and is served by the 1Password SSH agent — no key file is committed.

`install.sh` auto-writes `~/.ssh/mediapro_azure.pub` from 1Password on setup. To refresh it manually:

```bash
op item get "Azure DevOps - MediaPro" --vault "Developer Secrets" \
  --fields label="public key" --reveal > ~/.ssh/mediapro_azure.pub
```

Azure DevOps only accepts **RSA** SSH keys (ed25519 is rejected). The `gitdir:~/Workspace/work/improving/MediaPro/` include in `~/.gitconfig` scopes the MediaPro email and rewrites HTTPS / plain SSH URLs to the aliased host.

## iTerm2 setup

`./macos.sh` writes both Option Keys to **Esc+** and pins the profile font to **MesloLGS Nerd Font Mono**. Restart iTerm after running it.

- Option=Esc+ is what makes tmux see `Alt+letter` bindings; without it, dead-key layouts (Spanish/Latin) eat combos like `Alt+N` (rename window).
- MesloLGS NF is required by Powerlevel10k and the tmux Catppuccin status bar — without a Nerd Font the prompt and status bar render as boxes/`?`.

## Regenerating the Brewfile

```bash
brew bundle dump --file=~/dotfiles/Brewfile --force
```


---- 
🔹 The Gridcn — tema Tron https://thegridcn.com 
Un tema inspirado en Tron: Ares con 6 variantes (Tron, Ares, Clu, Athena, Aphrodite, Poseidon), efectos 3D con Three.js, glows neón y 50+ componentes. Perfecto para proyectos con identidad fuerte.

🔹 Glitchcn/ui — estética cyberpunk/hacker https://glitchcn-ui.vercel.app 
Componentes con scanlines animados, bordes que emiten luz cyan/emerald y tipografía monospace. Ideal para portfolios dev, dashboards técnicos o cualquier cosa que quiera verse como un terminal hackeado.

🔹 ElevenLabs UI — componentes para apps con IA y audio https://ui.elevenlabs.io 
Si estás construyendo chats tipo ChatGPT, voice agents o interfaces de audio: acá tienes waveforms en tiempo real, agent orbs con estados (idle/listening/talking), voice fill, reproductores. Open source y basado en shadcn.

🔹 UI TripleD — shadcn + Framer Motion https://ui.tripled.work
100+ bloques y páginas completas con animaciones listas. Incluye un Builder drag-and-drop para armar landings visualmente antes de copiar el código. Muy útil para prototipar MVPs.

🔹 mapcn — mapas estilo shadcn https://mapcn.dev
Componentes de mapa para React construidos sobre MapLibre y estilizados con Tailwind. Se sienten parte del mismo design system. Si alguna vez peleaste con Google Maps en un dashboard, esto te va a gustar.

🔹 shadcn/ui kit de Figma (shadcndesign) https://shadcndesign.com
Kit de Figma pixel-perfect + plugin que convierte diseños de Figma a código shadcn/ui real. Incluso tiene Agent Skills para que Claude, Cursor o Codex generen componentes desde un frame de Figma. El propio shadcn lo endorsó.

🔹 tweakcn — editor visual de temas https://tweakcn.com
El problema clásico: "todas las apps con shadcn se ven igual". tweakcn lo soluciona. 
Es un editor no-code donde customizas colores, tipografía, border radius, sombras y transiciones con preview en tiempo real, y exporta las variables CSS listas para Tailwind v3 o v4. Viene con presets hermosos para arrancar rápido y son Open source.
