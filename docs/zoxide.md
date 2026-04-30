# zoxide — Smarter cd

Replacement for `cd` that learns the directories you visit most. The more you visit a path, the higher its priority.

## Commands

```bash
# Jump to a directory by partial name
z fast                    # → ~/Workspace/EsquelDev/Templates/fastapi-template
z react                   # → ~/Workspace/EsquelDev/Templates/react-template
z landing                 # → ~/Workspace/EsquelDev/Projects/esquel-dev-landing

# If ambiguous, opens interactive fuzzy selector
zi                        # opens interactive selector with fzf

# Works with partial paths
z esquel land             # matches "esquel" + "landing"

# Go back to previous directory
z -
```

## How it learns

- Every time you `cd` or `z` into a directory, zoxide adds points to it.
- Directories you stop visiting lose points over time (frequency + recency).
- You can check the ranking:

```bash
zoxide query --list       # list all ranked directories
zoxide query fast         # see what "z fast" would resolve to
```

## Tips

- Keep using `cd` normally, zoxide tracks both.
- For exact paths, `cd` still works the same.
- `z` is for when you know where you want to go but don't want to type the full path.
