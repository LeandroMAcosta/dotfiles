# fzf — Fuzzy Finder

Interactive search tool that works on any list (files, history, branches, processes).

## Terminal shortcuts

| Shortcut | Action |
|----------|--------|
| `Ctrl+R` | Search command history |
| `Ctrl+T` | Search files in current directory |
| `Alt+C` | cd into a subdirectory (fuzzy) |

## Basic usage

```bash
# Find a file and open it in vim
vim $(fzf)

# Search files by content (combine with grep/rg)
grep -rl "TODO" . | fzf

# Filter any output
ps aux | fzf                    # find a process
git branch | fzf                # pick a branch
docker ps | fzf                 # pick a container
```

## Useful combinations

```bash
# Git checkout with fuzzy search
git checkout $(git branch --all | fzf)

# Kill a process
kill -9 $(ps aux | fzf | awk '{print $2}')

# Open a project file
vim $(find . -type f -name "*.py" | fzf)

# Preview files while searching (uses bat)
fzf --preview 'bat --color=always {}'
```

## Inside vim/neovim

If you use Telescope (neovim) or fzf.vim, the shortcuts are similar but work inside the editor.
