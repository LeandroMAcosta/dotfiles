# lazygit — Git UI in terminal

Visual interface for git that runs in the terminal. Partial staging, interactive rebase, merge, stash, all with keyboard shortcuts.

## Open

```bash
lazygit                   # open in current repo
lg                        # if you set up an alias (optional)
```

## Panels and navigation

| Key | Action |
|-----|--------|
| `Tab` / numbers `1-5` | Switch between panels |
| `j` / `k` | Navigate up/down |
| `h` / `l` | Navigate panels left/right |
| `Enter` | Expand / view details |
| `?` | View all shortcuts for current panel |
| `q` | Quit |

## Main panels

1. **Status** — Current branch, push/pull
2. **Files** — Modified files (staging area)
3. **Branches** — Local and remote branches
4. **Commits** — Commit history
5. **Stash** — Saved stashes

## Common operations

### Staging and commits
| Key | Action |
|-----|--------|
| `Space` | Stage/unstage a file |
| `a` | Stage/unstage all |
| `Enter` (on file) | View diff line by line |
| `Space` (on diff) | Stage/unstage individual lines |
| `c` | Commit |
| `A` | Amend last commit |

### Branches
| Key | Action |
|-----|--------|
| `n` | New branch |
| `Space` | Checkout branch |
| `M` | Merge branch into current |
| `r` | Rebase current branch onto another |
| `p` | Pull |
| `P` | Push |

### Commits
| Key | Action |
|-----|--------|
| `s` | Squash commit with previous |
| `r` | Reword commit message |
| `d` | Drop commit (in rebase) |
| `g` | Reset to selected commit |
| `Enter` | View commit files |

### Stash
| Key | Action |
|-----|--------|
| `s` (in files panel) | Stash changes |
| `Space` (in stash) | Apply stash |
| `g` (in stash) | Pop stash |

## Tips

- `x` on any panel shows a context menu with all available actions.
- Cherry-pick: `C` to copy a commit, navigate to the target branch, `V` to paste.
- To resolve conflicts: enter the conflicted file, it shows both sides and you choose with shortcuts.
