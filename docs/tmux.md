# tmux + tilish — Tiling Window Manager en la Terminal

Terminal multiplexer con keybindings estilo i3wm via [tmux-tilish](https://github.com/jabirali/tmux-tilish).

## Prefijo

El prefijo es `Ctrl+a` (en lugar del default `Ctrl+b`).

## Navegacion entre paneles

| Shortcut | Accion |
|----------|--------|
| `Alt + h` | Ir al panel izquierdo |
| `Alt + j` | Ir al panel de abajo |
| `Alt + k` | Ir al panel de arriba |
| `Alt + l` | Ir al panel derecho |
| `Alt + o` | Siguiente panel (ciclico) |

## Mover paneles

| Shortcut | Accion |
|----------|--------|
| `Alt + Shift + H` | Intercambiar con panel izquierdo |
| `Alt + Shift + J` | Intercambiar con panel de abajo |
| `Alt + Shift + K` | Intercambiar con panel de arriba |
| `Alt + Shift + L` | Intercambiar con panel derecho |

## Workspaces (ventanas)

| Shortcut | Accion |
|----------|--------|
| `Alt + 1-9` | Cambiar a workspace 1-9 |
| `Alt + Shift + 1-9` | Mover panel a workspace 1-9 |
| `Alt + n` | Renombrar workspace |

## Layouts

En tilish no se elige "split horizontal/vertical" al crear un panel. Se crea el panel con `Alt + Enter` y se elige un layout que reorganiza todos los paneles.

| Shortcut | Layout | Descripcion |
|----------|--------|-------------|
| `Alt + v` | main-vertical | Panel principal a la izquierda, resto apilados a la derecha |
| `Alt + s` | main-horizontal | Panel principal arriba, resto en fila abajo |
| `Alt + Shift + V` | even-horizontal | Todos en columnas iguales |
| `Alt + Shift + S` | even-vertical | Todos en filas iguales |
| `Alt + t` | tiled | Mosaico uniforme |
| `Alt + z` | zoom | Panel actual en pantalla completa (toggle) |
| `Alt + r` | — | Refrescar layout actual |

### Visualizacion de layouts

**main-vertical** (`Alt + v`):
```
┌──────┬────┐
│      │ 2  │
│  1   ├────┤
│      │ 3  │
└──────┴────┘
```

**main-horizontal** (`Alt + s`):
```
┌──────────┐
│    1     │
├────┬─────┤
│ 2  │  3  │
└────┴─────┘
```

**even-horizontal** (`Alt + Shift + V`):
```
┌───┬───┬───┐
│ 1 │ 2 │ 3 │
└───┴───┴───┘
```

**even-vertical** (`Alt + Shift + S`):
```
┌─────────┐
│    1    │
├─────────┤
│    2    │
├─────────┤
│    3    │
└─────────┘
```

**tiled** (`Alt + t`):
```
┌─────┬─────┐
│  1  │  2  │
├─────┼─────┤
│  3  │  4  │
└─────┴─────┘
```

Al agregar o cerrar paneles, tilish re-aplica el layout activo automaticamente.

## Crear y cerrar

| Shortcut | Accion |
|----------|--------|
| `Alt + Enter` | Nuevo panel (override: split horizontal) |
| `Alt + Shift + Q` | Cerrar panel |

## Otros

| Shortcut | Accion |
|----------|--------|
| `Alt + Shift + E` | Desconectarse (detach) |
| `Alt + Shift + C` | Recargar config |

## Shortcuts custom (fuera de tilish)

Definidos en `.tmux.conf`:

| Shortcut | Accion |
|----------|--------|
| `Ctrl+a \|` | Split horizontal |
| `Ctrl+a -` | Split vertical |
| `Shift + Left/Right` | Cambiar ventana anterior/siguiente |
| `Alt + Flechas` | Moverse entre paneles |
