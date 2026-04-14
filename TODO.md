# TODO

## Obsidian (esta Mac)

- [ ] Instalar plugins: Templater + Obsidian Git (desde Browse o terminal)
- [ ] Configurar Obsidian: new notes → `00-inbox`, attachments → `99-attachments`, Daily Notes → `10-daily/` con formato `YYYY-MM-DD`, wikilinks ON, auto-update links ON
- [ ] Crear templates: daily note y ADR (con Templater)
- [ ] Commitear `.obsidian/` al vault repo (para replicar config en otra Mac)

## Reorganizar ~/Workspace

- [ ] Mover de `~/Workspace/{EsquelDev, Taller, Improving}` a `~/Workspace/{work/{esqueldev, taller, improving}, personal, learning, sandbox}`
- [ ] Actualizar paths en `mprocs.yaml`, aliases de shell, IDE workspaces

## Git configs por identidad (dotfiles)

- [ ] Crear `.gitconfig` con `includeIf` por directorio (esqueldev, taller, personal) — email: leacosta97@gmail.com, misma SSH key por ahora
- [ ] Crear SSH host aliases: `github-esqueldev`, `github-taller`, `github-personal` (mismo key)
- [ ] Agregar carpeta `git/` al dotfiles + actualizar `install.sh`

## Skills de Claude Code

- [ ] Instalar Tier 1: `antonbabenko/terraform-skill`, `hashicorp/agent-skills`, `trailofbits/skills`
- [ ] Agregar Tier 1 a `install.sh`

## Sync entre Macs

- [ ] Setup en otra Mac: `git clone` del vault + abrir con Obsidian
