# Neovim + Claude Code — Full Setup Guide

Complete guide to set up Neovim with LazyVim and Claude Code integration.

## 1. Install LazyVim

LazyVim is a Neovim distro that comes with everything preconfigured: LSP, autocompletado, file explorer, fuzzy finder, git, etc.

```bash
# Backup existing config (if any)
mv ~/.config/nvim ~/.config/nvim.bak 2>/dev/null

# Clone LazyVim starter
git clone https://github.com/LazyVim/starter ~/.config/nvim
rm -rf ~/.config/nvim/.git

# Open neovim — plugins install automatically
nvim
```

Wait for all plugins to finish installing, then restart nvim.

## 2. Learn the basics

### Vim fundamentals (run `vimtutor` first)

| Key | Action |
|-----|--------|
| `i` | Enter insert mode (type text) |
| `Esc` | Back to normal mode |
| `h/j/k/l` | Move left/down/up/right |
| `w` / `b` | Jump forward/back by word |
| `dd` | Delete line |
| `yy` | Copy line |
| `p` | Paste |
| `/text` | Search for "text" |
| `u` | Undo |
| `Ctrl+r` | Redo |
| `:w` | Save |
| `:q` | Quit |
| `:wq` | Save and quit |

### LazyVim shortcuts (Space is the leader key)

Press `Space` and wait — a menu appears showing all available actions.

| Shortcut | Action |
|----------|--------|
| `Space + f + f` | Find files (like Ctrl+P in VS Code) |
| `Space + /` | Search text in project (like Ctrl+Shift+F) |
| `Space + e` | Toggle file explorer |
| `Space + b + b` | Switch between open buffers |
| `g + d` | Go to definition |
| `g + r` | Go to references |
| `K` | Show hover docs |
| `Space + c + a` | Code actions |
| `Space + c + r` | Rename symbol |
| `Space + x + x` | Show diagnostics (errors/warnings) |
| `Space + g + g` | Open lazygit |
| `Space + q + q` | Quit all |

## 3. Set up Claude Code integration

### Install claudecode.nvim

This is the official Neovim plugin for Claude Code. It creates a WebSocket connection so Claude Code can see your files, cursor position, and you can accept/reject changes directly in Neovim.

Create the plugin file:

```bash
cat > ~/.config/nvim/lua/plugins/claude.lua << 'EOF'
return {
  {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    opts = {
      split_side = "right",
      split_width_percentage = 0.35,
    },
  },
}
EOF
```

Open `nvim` and the plugin installs automatically.

### Key bindings for Claude

| Shortcut | Action |
|----------|--------|
| `Space + a + c` | Toggle Claude Code terminal |
| `Space + a + f` | Focus Claude Code terminal |
| `Space + a + r` | Resume Claude session |
| `Space + a + C` | Continue conversation |
| `Space + a + b` | Add current buffer to context |

### How it works

1. Open neovim in your project: `nvim .`
2. Press `Space + a + c` to open Claude Code inside neovim
3. Claude automatically sees your current file and cursor position
4. When Claude proposes changes, you see a native diff view
5. Accept or reject changes with keybindings
6. File changes sync bidirectionally

## 4. tmux — Managing neovim + Claude side by side

tmux lets you split your terminal into multiple panes. Even without claudecode.nvim, you can run neovim and Claude Code side by side.

### tmux cheat sheet

All tmux commands start with `Ctrl+b` (the prefix), then a key:

#### Sessions

```bash
tmux new -s work              # create a session named "work"
tmux ls                       # list sessions
tmux attach -t work           # reattach to "work"
tmux kill-session -t work     # kill session
```

| Shortcut | Action |
|----------|--------|
| `Ctrl+b d` | Detach from session (keeps running) |
| `Ctrl+b $` | Rename session |
| `Ctrl+b s` | List/switch sessions |

#### Windows (tabs)

| Shortcut | Action |
|----------|--------|
| `Ctrl+b c` | Create new window |
| `Ctrl+b ,` | Rename window |
| `Ctrl+b n` / `Ctrl+b p` | Next / previous window |
| `Ctrl+b 0-9` | Jump to window by number |

#### Panes (splits)

| Shortcut | Action |
|----------|--------|
| `Ctrl+b %` | Split vertically (left/right) |
| `Ctrl+b "` | Split horizontally (top/bottom) |
| `Ctrl+b ←/→/↑/↓` | Navigate between panes |
| `Ctrl+b z` | Zoom/unzoom current pane (fullscreen toggle) |
| `Ctrl+b x` | Close current pane |
| `Ctrl+b Space` | Cycle pane layouts |

### Recommended workflow

```bash
# Start a tmux session
tmux new -s dev

# Split vertically: neovim on the left, Claude on the right
# (Ctrl+b %)

# Left pane: open neovim
nvim .

# Right pane (Ctrl+b →): run Claude Code
claude

# Switch between panes: Ctrl+b ← and Ctrl+b →
# Zoom into one pane: Ctrl+b z (toggle)
```

### With claudecode.nvim (recommended)

You don't even need tmux panes — Claude runs inside neovim:

```bash
tmux new -s dev
nvim .
# Press Space + a + c to open Claude inside neovim
```

This is the cleanest setup because Claude has full context of your editor state.

## 5. Recommended workflow summary

### Option A: All inside neovim (simplest)

```
nvim .  →  Space+ac to toggle Claude  →  work normally
```

Claude sees your files, cursor, selections. Changes appear as diffs you accept/reject.

### Option B: tmux split (more screen space)

```
┌─────────────────┬──────────────────┐
│                  │                  │
│     neovim       │   claude code    │
│                  │                  │
│                  │                  │
└─────────────────┴──────────────────┘
```

Claude edits files directly. Neovim auto-reloads changed files.

### Option C: Keep using Cursor/VS Code

Neovim is a long-term investment. Start small:
- Use neovim for config files, quick edits, git commits
- Keep Cursor for heavy development
- Migrate gradually as you get comfortable

## Tips

- Run `vimtutor` at least twice before trying to be productive in neovim.
- Don't try to learn everything at once. Learn 2-3 new shortcuts per week.
- Press `Space` and read the menu — LazyVim is very discoverable.
- `:Lazy` opens the plugin manager to update or install plugins.
- `:Mason` opens the LSP/formatter manager to install language servers.
- If you get stuck, `:q!` quits without saving. Always works.
