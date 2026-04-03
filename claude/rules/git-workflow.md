## Git Workflow

- Commit messages: one short line, < 72 chars, no body, no bullet lists.
- Never add Co-Authored-By lines.
- Never use --no-verify or skip pre-commit hooks.
- Never force push to main/master.
- Prefer specific `git add <file>` over `git add -A` or `git add .`.
- Never commit .env files, credentials, or secrets.
