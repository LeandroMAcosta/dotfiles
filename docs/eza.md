# eza — Better ls

Modern replacement for `ls` with colors, icons, and built-in git status.

## Configured aliases

Already set up in `.zshrc`:

```bash
ls                        # eza --icons --group-directories-first
ll                        # eza --icons --group-directories-first -la
lt                        # eza --icons --tree --level=2
```

## Useful flags

```bash
# Deeper tree
eza --tree --level=3

# Directories only
eza -D

# Sort by size
eza -la --sort=size

# Sort by modification (most recent first)
eza -la --sort=modified

# Show git status per file
eza -la --git
# M = modified, N = new, - = unchanged

# Filter by extension
eza *.py

# Header with columns (table-like)
eza -la --header
```

## Comparison with ls

| ls | eza |
|----|-----|
| `ls -la` | `ll` |
| `ls -R` | `lt` (but with visual tree) |
| N/A | `--git` shows git status |
| N/A | `--icons` shows file type icons |
