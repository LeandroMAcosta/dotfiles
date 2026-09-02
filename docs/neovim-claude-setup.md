# Neovim + Claude Code — Full Setup Guide

Complete guide to set up Neovim with LazyVim and Claude Code integration.

## 1. Install LazyVim

LazyVim is a Neovim distro that comes with everything preconfigured: LSP, autocomplete, file explorer, fuzzy finder, git, etc.

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

## 3. Claude Code integration

Two independent mechanisms exist. **The one actually in use is the file watcher
(3a).** claudecode.nvim (3b) is installed but deliberately dormant.

### 3a. Follow-the-change file watcher (active)

Claude runs in its own terminal pane and edits files straight on disk. Nothing
blocks it, and no accept/reject prompt interrupts it. `lua/config/autocmds.lua`
then makes nvim follow along:

- `autoread` plus a 1s `checktime` poll reloads changed buffers, even while nvim
  is unfocused.
- A recursive `vim.uv.new_fs_event()` watcher on the cwd is a faster trigger —
  it debounces write bursts by 80ms and then runs `checktime`. It re-arms on
  `DirChanged`, so `:cd` is followed.
- `BufReadPost` / `BufWritePost` keep a snapshot of each buffer plus the one
  before it. On an autoread reload the events fire in the order `BufReadPre`,
  `BufReadPost`, `FileChangedShellPost`, so by diff time the current snapshot
  already holds the *new* contents — the previous one is what makes the diff
  possible.
- `FileChangedShellPost` diffs the two snapshots with `vim.diff`, moves the
  cursor to the first changed line in every window showing that buffer, centers
  it, and flashes the changed ranges (`ClaudeChangeFlash`, linked to `DiffAdd`)
  for one second. gitsigns keeps marking them afterwards.

What it deliberately does **not** do:

- It never opens a file you do not already have open — no window hijacking.
- It never steals focus. A change in a background split scrolls into view while
  your cursor stays where it is.
- It never touches a buffer with unsaved local changes; you get nvim's standard
  `W12` warning instead.
- Buffers over 20000 lines reload normally but are not diffed.

### 3b. claudecode.nvim (installed, dormant)

Pulled in by the `lazyvim.plugins.extras.ai.claudecode` extra in `lazyvim.json`,
so no `lua/plugins/claude.lua` is needed. It speaks the same WebSocket protocol
as the VS Code extension: native diffs you accept or reject, plus cursor and
selection sharing.

It is lazy-loaded on its keymaps only, so its server does not start on its own
and `~/.claude/ide/` stays empty. To use it: press `Space + a + c` once (that
loads the plugin and starts the server), then run `/ide` in an external Claude
session to connect — or just work inside the terminal it opens.

| Shortcut | Action |
|----------|--------|
| `Space + a + c` | Toggle Claude Code terminal |
| `Space + a + f` | Focus Claude Code terminal |
| `Space + a + r` | Resume Claude session |
| `Space + a + C` | Continue conversation |
| `Space + a + b` | Add current buffer to context |
| `Space + a + a` | Accept the proposed diff |
| `Space + a + d` | Reject the proposed diff |

Note the two mechanisms overlap: with a diff open, the watcher's `checktime` is
harmless (diff buffers are not file buffers), but the accept/reject flow is the
authority on what lands on disk.

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

### With claudecode.nvim

You don't even need tmux panes — Claude runs inside neovim:

```bash
tmux new -s dev
nvim .
# Press Space + a + c to open Claude inside neovim
```

Claude then has full context of your editor state, at the cost of every edit
waiting on an accept/reject. The split-pane setup above is the one in use here.

## 5. Recommended workflow summary

### Option A: All inside neovim

```
nvim .  →  Space+ac to toggle Claude  →  work normally
```

Claude sees your files, cursor, selections. Changes appear as diffs you accept/reject.

### Option B: tmux split (in use here)

```
┌─────────────────┬──────────────────┐
│                  │                  │
│     neovim       │   claude code    │
│                  │                  │
│                  │                  │
└─────────────────┴──────────────────┘
```

Claude edits files directly. Neovim reloads them and moves the cursor onto the
changed lines (see §3a).

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
