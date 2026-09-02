#!/usr/bin/env bash
set -euo pipefail

# Local plaintext secrets file, kept out of the repo. Create it empty with
# tight perms if missing so ~/.zshrc can source it; user fills it in by hand.
if [[ ! -f "$HOME/.secrets" ]]; then
  printf '# Local plaintext secrets — never committed. chmod 600. export VAR=value\n' > "$HOME/.secrets"
  chmod 600 "$HOME/.secrets"
  echo "  Created empty ~/.secrets (fill in by hand, never committed)"
fi
