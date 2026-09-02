# dotfiles

My development environment configuration — macOS today, Arch Linux ready.
Managed with [chezmoi](https://www.chezmoi.io): one repo, one branch, per-OS
differences handled by templates (`{{ if eq .chezmoi.os "darwin" }}`) instead
of separate repos or branches.

## What's included

| Path | Description |
|------|-------------|
| `home/` | chezmoi source state (selected by `.chezmoiroot`) — everything deployed into `$HOME` |
| `home/dot_zshrc.tmpl` | Zsh config (Oh My Zsh + Powerlevel10k), OS-branched |
| `home/dot_config/` | tmux, nvim (LazyVim), yazi, ghostty, herdr, opencode, 1Password |
| `home/dot_claude/` | Claude Code global config (settings, rules, contexts) |
| `home/private_dot_ssh/` | SSH hosts (1Password agent socket per OS) |
| `home/.chezmoiexternal.toml` | OMZ, p10k, zsh plugins, TPM — auto-installed and refreshed |
| `home/.chezmoiscripts/` | brew bundle, macOS defaults + iTerm sync, SSH keys from 1Password, tmux plugins, Claude skills, Arch packages (stub) |
| `Brewfile` | Homebrew packages and casks; hashed into the darwin script, so editing it triggers `brew bundle` on next apply |
| `linux/README.md` | Playbook for the future Arch machine (Omarchy vs CachyOS) |
| `install.sh` | Bootstrap: installs chezmoi, then `chezmoi init --apply` |

## Quick start

```bash
git clone git@github.com:LeandroMAcosta/dotfiles.git ~/Workspace/personal/dotfiles
cd ~/Workspace/personal/dotfiles
./install.sh
```

## Day to day

```bash
chezmoi diff      # preview what apply would change
chezmoi apply     # deploy repo -> $HOME (runs scripts, refreshes externals)
chezmoi re-add    # capture edits made directly in $HOME back into the repo
```

Add a new config: `chezmoi add ~/.config/<app>` (creates the source under
`home/dot_config/<app>`), then commit. For OS-specific content, rename to
`.tmpl` and branch on `.chezmoi.os`.

## Workspace structure

All code lives under `~/Workspace/`, organized by purpose:

```
~/Workspace/
├── work/        # Client / employer projects, grouped by org
│   ├── engbim/      # own workspace: repos/, docs/, notes/, unity/, ...
│   ├── esqueldev/   # workspace, infra-core, esquel-ai*, futala-*, origen-global, ...
│   ├── goply/       # goply-iac, goply-backend, goply-frontend, yendo-mobile
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

### Tmux (prefix: `Ctrl+A`)

| Shortcut | Action |
|----------|--------|
| `Ctrl+A, \|` | Split vertical (side by side) |
| `Ctrl+A, -` | Split horizontal (top/bottom) |
| `Ctrl+A, r` | Reload config |
| `Alt+←/→/↑/↓` | Move between panes |
| `Alt+Shift+←/→/↑/↓` | Swap panes |
| `Alt+Enter` | New vertical split in current path |
| `Alt+Shift+Q` | Close pane |
| `Shift+←/→` | Switch windows |
| `Ctrl+A, [` | Enter copy mode (vi keys) |
| `v` (copy mode) | Start selection |
| `y` (copy mode) | Copy to clipboard |

## MediaPro (Azure DevOps) SSH setup

The ssh config defines `Host ssh.dev.azure.com-mediapro` with `IdentityFile ~/.ssh/mediapro_azure.pub`. The private key lives in 1Password (item **Azure DevOps - MediaPro**, vault *Developer Secrets*) and is served by the 1Password SSH agent — no key file is committed. To write the public key manually:

```bash
op item get "Azure DevOps - MediaPro" --vault "Developer Secrets" \
  --fields label="public key" --reveal > ~/.ssh/mediapro_azure.pub
```

Azure DevOps only accepts **RSA** SSH keys (ed25519 is rejected). The `gitdir:~/Workspace/work/improving/MediaPro/` include in `~/.gitconfig` scopes the MediaPro email and rewrites HTTPS / plain SSH URLs to the aliased host.

## iTerm2 setup (macOS)

The darwin defaults script (runs on `chezmoi apply`, restart iTerm after) writes both Option Keys to **Esc+** and pins the profile font to **MesloLGS Nerd Font Mono**, and syncs one profile per terminal mode (`Default` plain shell, `tmux`, `herdr`).

- Option=Esc+ is what makes tmux see `Alt+letter` bindings; without it, dead-key layouts (Spanish/Latin) eat combos like `Alt+N` (rename window).
- MesloLGS NF is required by Powerlevel10k and the tmux Catppuccin status bar — without a Nerd Font the prompt and status bar render as boxes/`?`.

## Regenerating the Brewfile

```bash
brew bundle dump --file=~/Workspace/personal/dotfiles/Brewfile --force
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
