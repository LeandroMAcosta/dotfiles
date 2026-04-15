# TODO

## Obsidian (esta Mac)

- [ ] Instalar plugins: Templater + Obsidian Git (desde Browse o terminal)
- [ ] Configurar Obsidian: new notes → `00-inbox`, attachments → `99-attachments`, Daily Notes → `10-daily/` con formato `YYYY-MM-DD`, wikilinks ON, auto-update links ON
- [ ] Crear templates: daily note y ADR (con Templater)
- [ ] Commitear `.obsidian/` al vault repo (para replicar config en otra Mac)

## Reorganizar ~/Workspace (HECHO)

Estructura final:

```
~/Workspace/
├── work/
│   ├── esqueldev/
│   │   ├── products/
│   │   │   ├── futala/                # multi-tenant platform
│   │   │   │   ├── futala-api/
│   │   │   │   ├── futala-admin/
│   │   │   │   ├── highland-tickets/
│   │   │   │   ├── futala-infra/
│   │   │   │   ├── specs/
│   │   │   │   ├── mprocs.yaml
│   │   │   │   ├── CLAUDE.md
│   │   │   │   ├── docker-compose.highland.yml
│   │   │   │   └── docker-compose.futala-admin.yml
│   │   │   ├── esquel-dev-landing/
│   │   │   └── esquel-ai/
│   │   ├── platform/infra-core/
│   │   ├── templates/{fastapi,fastapi-serverless,react,infra-ec2,infra-serverless}/
│   │   └── sandbox/ai-playground/
│   ├── taller/
│   └── improving/
├── personal/
│   ├── dotfiles/                      # este repo
│   ├── finance/
│   ├── LatexCV/
│   ├── my-cv/
│   └── side-projects/
│       ├── fastapi-boilerplate/
│       ├── claude-remote-server/
│       ├── cv-tex/
│       ├── oop/
│       ├── scrapper-codes/
│       └── tesis_2/
├── learning/aws-saa/{notes,labs,practice-exams}/
├── archive/                           # legacy / proyectos pasados
│   ├── canalytics/
│   ├── yendo/
│   └── highland-prototype/            # prototipo monolitico viejo
└── sandbox/                           # experimentos descartables
```

Criterio para nuevos proyectos:
- Producto propio → `work/esqueldev/products/<nombre>/`
- Cliente que paga → `work/esqueldev/clients/<cliente>/` o `work/<empresa>/`
- Infra/tooling cross-product → `work/esqueldev/platform/`
- Template reusable → `work/esqueldev/templates/`
- Estudio → `learning/<tema>/`
- Side project personal → `personal/side-projects/`
- Experimento descartable → `sandbox/`
- Archivo muerto → `archive/`

Tareas:
- [x] Crear estructura de directorios destino
- [x] Mover repos de EsquelDev a `work/esqueldev/` (products, platform, templates)
- [x] Mover dotfiles a `personal/dotfiles/`
- [x] Mover Taller e Improving a `work/taller/` y `work/improving/`
- [x] Mover `mprocs.yaml` y `CLAUDE.md` de EsquelDev a `work/esqueldev/products/futala/`
- [x] Actualizar paths en `mprocs.yaml` (sin `Projects/` prefix)
- [x] Archivar Canalytics, Yendo, Code/highland
- [x] Mover Code/ (fastapi-boilerplate, claude-remote-server, my-cv, cv, oop, scrapper, tesis) a personal
- [x] Actualizar `work/esqueldev/CLAUDE.md` con nueva jerarquia
- [x] Crear `work/esqueldev/products/futala/CLAUDE.md`
- [ ] Actualizar IDE workspaces/recientes (Cursor, `.code-workspace` referencia paths viejos)
- [ ] Verificar que dev servers arrancan correctamente despues del move (correr `mprocs` desde futala/)

## Obsidian vault (ya creado)

Vault en `~/vault/` (fuera de Workspace, sincronizado por git):

```
~/vault/                              # repo: LeandroMAcosta/vault (privado)
├── CLAUDE.md
├── 00-inbox/                         # captura rapida, triage despues
├── 10-daily/                         # journal diario (YYYY-MM-DD.md)
├── 20-work/
│   ├── esqueldev/                    # notas de esquel.dev
│   └── taller/                       # notas de Taller
├── 30-personal/
├── 40-learning/
│   └── aws-saa/                      # estudio AWS SAA
├── 90-areas/                         # ongoing sin fin (salud, finanzas)
└── 99-attachments/                   # imagenes, PDFs referenciados
```

Notas en el vault, codigo en `~/Workspace/`. Dos capas paralelas.

## Git configs por identidad (dotfiles)

Agregar al dotfiles y a `install.sh`:

- [ ] `git/gitconfig` → `~/.gitconfig` — default personal + `includeIf` por directorio:
  - `gitdir:~/Workspace/work/esqueldev/` → `~/.gitconfig-esqueldev`
  - `gitdir:~/Workspace/work/taller/` → `~/.gitconfig-taller`
  - `gitdir:~/Workspace/work/improving/` → `~/.gitconfig-improving`
- [ ] `git/gitconfig-esqueldev` → `~/.gitconfig-esqueldev` (email: leacosta97@gmail.com, key: id_ed25519_leacosta97)
- [ ] `git/gitconfig-taller` → `~/.gitconfig-taller` (misma credencial por ahora)
- [ ] `git/gitconfig-personal` → `~/.gitconfig-personal` (misma credencial por ahora)
- [ ] SSH host aliases en `ssh/config`: `github-esqueldev`, `github-taller`, `github-personal` (mismo IdentityFile por ahora, separados para futura independencia)
- [ ] Actualizar `install.sh` para copiar gitconfigs

## Skills de Claude Code

- [ ] Instalar Tier 1: `antonbabenko/terraform-skill`, `hashicorp/agent-skills`, `trailofbits/skills`
- [ ] Agregar Tier 1 a `install.sh`

## Sync entre Macs

- [ ] En otra Mac: `git clone https://github.com/LeandroMAcosta/vault.git ~/vault`
- [ ] Abrir Obsidian → "Open folder as vault" → `~/vault/`
- [ ] Plugins y config ya vienen del repo (si se commiteo `.obsidian/`)
