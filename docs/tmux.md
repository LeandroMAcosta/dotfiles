# tmux + tilish — Tiling Window Manager in the Terminal

Terminal multiplexer with i3wm-style keybindings via [tmux-tilish](https://github.com/jabirali/tmux-tilish).

## Prefix

The prefix is `Ctrl+Space` (instead of the default `Ctrl+b`).

## Pane navigation

| Shortcut | Action |
|----------|--------|
| `Alt + h` | Go to left pane |
| `Alt + j` | Go to pane below |
| `Alt + k` | Go to pane above |
| `Alt + l` | Go to right pane |
| `Alt + o` | Next pane (cyclic) |

## Move panes

| Shortcut | Action |
|----------|--------|
| `Alt + Shift + H` | Swap with left pane |
| `Alt + Shift + J` | Swap with pane below |
| `Alt + Shift + K` | Swap with pane above |
| `Alt + Shift + L` | Swap with right pane |

## Workspaces (windows)

| Shortcut | Action |
|----------|--------|
| `Alt + 1-9` | Switch to workspace 1-9 |
| `Alt + Shift + 1-9` | Move pane to workspace 1-9 |
| `Alt + n` | Rename workspace |

## Layouts

In tilish you don't choose "horizontal/vertical split" when creating a pane. You create the pane with `Alt + Enter` and choose a layout that reorganizes all panes.

| Shortcut | Layout | Description |
|----------|--------|-------------|
| `Alt + v` | main-vertical | Main pane on the left, rest stacked on the right |
| `Alt + s` | main-horizontal | Main pane on top, rest in a row below |
| `Alt + Shift + V` | even-horizontal | All in equal columns |
| `Alt + Shift + S` | even-vertical | All in equal rows |
| `Alt + t` | tiled | Uniform mosaic |
| `Alt + z` | zoom | Current pane fullscreen (toggle) |
| `Alt + r` | — | Refresh current layout |

### Layout visualization

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

When adding or closing panes, tilish re-applies the active layout automatically.

## Create and close

| Shortcut | Action |
|----------|--------|
| `Alt + Enter` | New pane (override: horizontal split) |
| `Alt + Shift + Q` | Close pane |

## Other

| Shortcut | Action |
|----------|--------|
| `Alt + Shift + E` | Detach |
| `Alt + Shift + C` | Reload config |

## Custom shortcuts (outside tilish)

Defined in `.tmux.conf`:

| Shortcut | Action |
|----------|--------|
| `Ctrl+Space \|` | Horizontal split |
| `Ctrl+Space -` | Vertical split |
| `Shift + Left/Right` | Previous/next window |
| `Alt + Arrows` | Move between panes |
| `Alt + Ctrl + Arrows` | Resize pane (2 cells) |
