# TODO

## Obsidian (esta Mac)

- [ ] Instalar plugins: Templater + Obsidian Git (desde Browse o terminal)
- [ ] Configurar Obsidian: new notes → `00-inbox`, attachments → `99-attachments`, Daily Notes → `10-daily/` con formato `YYYY-MM-DD`, wikilinks ON, auto-update links ON
- [ ] Crear templates: daily note y ADR (con Templater)
- [ ] Commitear `.obsidian/` al vault repo (para replicar config en otra Mac)

## Reorganizar ~/Workspace

Estructura actual:

```
~/Workspace/
├── EsquelDev/          # estudio propio (GitHub org: EsquelDev)
│   ├── futala-api/
│   ├── highland-tickets/
│   ├── futala-admin/
│   ├── futala-infra/
│   ├── esquel-dev-landing/
│   ├── infra-core/
│   └── dotfiles/       # este repo
├── Taller/             # empleador/cliente
└── Improving/          # empleador/cliente
```

Estructura destino:

```
~/Workspace/
├── work/
│   ├── esqueldev/                     # estudio propio
│   │   ├── products/
│   │   │   ├── futala/                # plataforma multi-tenant (cohesive)
│   │   │   │   ├── futala-api/
│   │   │   │   ├── futala-admin/
│   │   │   │   ├── highland-tickets/
│   │   │   │   ├── futala-infra/
│   │   │   │   ├── specs/
│   │   │   │   ├── mprocs.yaml
│   │   │   │   └── CLAUDE.md
│   │   │   └── esquel-dev-landing/    # sitio corporativo standalone
│   │   ├── clients/                   # trabajo para terceros via EsquelDev
│   │   ├── platform/
│   │   │   └── infra-core/            # AWS Org, IAM, billing (cross-product)
│   │   ├── templates/
│   │   │   ├── fastapi-template/
│   │   │   ├── fastapi-serverless-template/
│   │   │   ├── react-template/
│   │   │   ├── infra-ec2-template/
│   │   │   └── infra-serverless-template/
│   │   └── sandbox/                   # experimentos de EsquelDev
│   ├── taller/                        # empleador/cliente
│   └── improving/                     # empleador/cliente
├── personal/
│   ├── dotfiles/                      # este repo (mover aca)
│   └── side-projects/
├── learning/
│   ├── aws-saa/
│   │   ├── notes/                     # linkeable con Obsidian vault
│   │   ├── labs/                      # Terraform hands-on
│   │   └── practice-exams/
│   └── otros-cursos/
└── sandbox/                           # experimentos personales throwaway
```

Criterio para nuevos proyectos:
- Producto propio → `work/esqueldev/products/<nombre>/`
- Cliente que paga → `work/esqueldev/clients/<cliente>/` o `work/<empresa>/`
- Infra/tooling cross-product → `work/esqueldev/platform/`
- Template reusable → `work/esqueldev/templates/`
- Estudio → `learning/<tema>/`
- Experimento descartable → `sandbox/`

Tareas:
- [ ] Crear estructura de directorios destino
- [ ] Mover repos de EsquelDev a `work/esqueldev/` (products, platform, templates)
- [ ] Mover dotfiles a `personal/dotfiles/`
- [ ] Mover Taller e Improving a `work/taller/` y `work/improving/`
- [ ] Mover `mprocs.yaml` y `CLAUDE.md` de EsquelDev a `work/esqueldev/products/futala/`
- [ ] Actualizar paths en `mprocs.yaml` (relativos a nueva ubicacion)
- [ ] Actualizar aliases de shell que referencien `~/Workspace/EsquelDev`
- [ ] Actualizar IDE workspaces/recientes (Cursor, etc.)
- [ ] Verificar que dev servers arrancan correctamente despues del move

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
